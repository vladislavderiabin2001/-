#!/usr/bin/env python3
from bcc import BPF
from time import sleep
from collections import defaultdict
import subprocess

proc = subprocess.Popen(["/opt/scripts/generate_activity.sh"])

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <linux/sched.h>

BPF_HASH(counter, u32);

int trace_exec(struct pt_regs *ctx, struct task_struct *p) {
    u32 pid = p->pid;
    u64 zero = 0, *val;
    val = counter.lookup_or_init(&pid, &zero);
    (*val)++;
    return 0;
}
"""

b = BPF(text=bpf_text)
b.attach_kprobe(event="do_execveat_common", fn_name="trace_exec")

print("Собираем статистику процессов 10 минут...")
sleep(600)

proc.terminate()
proc.wait()

data = defaultdict(int)
for k, v in b["counter"].items():
    data[k.value] = v.value

print("\nPID\tЗапущено процессов/тредов")
for pid, count in data.items():
    print(f"{pid}\t{count}")