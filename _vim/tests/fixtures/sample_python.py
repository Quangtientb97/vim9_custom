clean_line = ANSI_ESCAPE_PATTERN.sub('', raw_line).strip()
if not clean_line:
    continue
if re.search(r"^No\s+(active\s+)?(zellij\s+)?sessions", clean_line, re.IGNORECASE):
    continue

parts = clean_line.split()
if parts:
    session_name = parts[0]
    sessions.append((clean_line, session_name))

return sessions


def run_rename(old_name, new_name):
    # Attempt rename via standard action commands
    cmd1 = f"{ZELLIJ_BIN} --session {old_name} action rename-session {new_name}"
    res = subprocess.run(cmd1, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    if res.returncode == 0:
        return True

    cmd2 = f"{ZELLIJ_BIN} -s {old_name} action rename-session {new_name}"
    res2 = subprocess.run(cmd2, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    if res2.returncode == 0:
        return True
    else:
        return False


def run_delete(target_name):
    # Attempt force deletion across varying CLI option orders
    cmd1 = f"{ZELLIJ_BIN} delete-session --force {target_name}"
    res = subprocess.run(cmd1, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    if res.returncode == 0:
        return True

import sys
from os import path as p


class register_c(register_base_c):
    def compose(self):
        super().compose()


class field_c(field_base_c):
    def compose(self):
        super().compose()


for reserved_field in xml_reg.iter('reserved'):
    field = field_c()
    addr_val = int("0x10", 16)
