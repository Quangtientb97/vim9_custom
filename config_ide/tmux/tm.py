#!/usr/bin/env python3
# ==============================================================================
# Script: tm.py
# Description: Interactive Tmux session manager CLI script in Python
# ==============================================================================

import os
import re
import shutil
import socket
import subprocess
import sys
import termios
import time
import tty


def get_tmux_bin():
    # Determine binary path based on host identity and file availability
    hostname = socket.gethostname()
    if hostname == "tientq-dv":
        return "tmux"
    else:
        server_bin = "/mnt/users/tientq/Apps/tmux"
        if os.path.isfile(server_bin) and os.access(server_bin, os.X_OK):
            return server_bin
        else:
            return "tmux"


TMUX_BIN = get_tmux_bin()
ANSI_ESCAPE_PATTERN = re.compile(r"\x1B\[[0-9;]*[a-zA-Z]")


def get_sessions():
    # Query tmux for active sessions
    try:
        proc = subprocess.run(
            f"{TMUX_BIN} list-sessions",
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=False,
        )
    except FileNotFoundError:
        return []

    if proc.returncode != 0:
        return []

    lines = proc.stdout.splitlines()
    sessions = []

    for raw_line in lines:
        clean_line = ANSI_ESCAPE_PATTERN.sub("", raw_line).strip()
        if not clean_line:
            continue
        if re.search(r"no server running|failed to connect|error connecting", clean_line, re.IGNORECASE):
            continue

        parts = clean_line.split(":")
        if parts:
            session_name = parts[0].strip()
            sessions.append((clean_line, session_name))

    return sessions


def run_rename(old_name, new_name):
    # Attempt rename via tmux rename-session
    cmd = f'{TMUX_BIN} rename-session -t "{old_name}" "{new_name}"'
    res = subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    if res.returncode == 0:
        return True
    else:
        return False


def run_delete(target_name):
    # Attempt kill via tmux kill-session
    cmd = f'{TMUX_BIN} kill-session -t "{target_name}"'
    res = subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    if res.returncode == 0:
        return True
    else:
        return False


def get_single_char():
    # Read a single character directly without waiting for Enter
    if not sys.stdin.isatty():
        while True:
            ch = sys.stdin.read(1)
            if not ch:
                return "q"
            if ch not in ("\n", "\r"):
                return ch

    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch


def read_selection(count, prompt_str):
    sys.stdout.write(prompt_str)
    sys.stdout.flush()

    try:
        ch = get_single_char()
    except (KeyboardInterrupt, EOFError):
        print()
        return "q"

    if ch in ("q", "Q", "\x03", "\x04"):
        print(ch)
        return "q"

    if ch in ("c", "C"):
        print(ch)
        return "c"

    if ch in ("r", "R"):
        print(ch)
        return "r"

    if ch in ("d", "D"):
        print(ch)
        return "d"

    if ch.isdigit():
        # Buffer digits and wait for explicit Enter confirmation
        digits = [ch]
        sys.stdout.write(ch)
        sys.stdout.flush()

        while True:
            try:
                next_ch = get_single_char()
            except (KeyboardInterrupt, EOFError):
                print()
                return "q"

            if next_ch in ("\n", "\r"):
                print()
                if digits:
                    return "".join(digits)
                else:
                    return ""
            elif next_ch in ("\x7f", "\x08"):
                if digits:
                    digits.pop()
                    sys.stdout.write("\b \b")
                    sys.stdout.flush()
            elif next_ch.isdigit():
                digits.append(next_ch)
                sys.stdout.write(next_ch)
                sys.stdout.flush()
            elif next_ch in ("\x03", "\x04", "\x1b", "q", "Q"):
                print()
                return "q"
            elif not digits and next_ch in ("c", "C"):
                print(next_ch)
                return "c"
            elif not digits and next_ch in ("r", "R"):
                print(next_ch)
                return "r"
            elif not digits and next_ch in ("d", "D"):
                print(next_ch)
                return "d"

    print(ch)
    return ch


def print_cheatsheet():
    # Display essential Tmux keybindings and commands cheatsheet
    cheatsheet_text = """================================================================================
                           TMUX ESSENTIAL CHEATSHEET
================================================================================
Prefix Key: Ctrl + b (press Prefix first, release, then press command key)

[ 1. SESSION MANAGEMENT ]
  Ctrl + b  d         Detach from session (leaves processes running safely)
  Ctrl + b  s         Interactive session switcher
  Ctrl + b  $         Rename current session

[ 2. WINDOW (TAB) MANAGEMENT ]
  Ctrl + b  c         Create new window (tab) with rename prompt
  Ctrl + b  m         Move Tab mode (Left/Right or h/l to slide tab, Enter to done)
  Ctrl + b  r / ,     Rename current window (tab)
  Ctrl + b  n / p     Go to Next / Previous window
  Ctrl + b  0..9      Switch directly to window by number
  Ctrl + b  w         List all windows interactively
  Ctrl + b  x / &     Kill / close current window (tab)

[ 3. PANE MANAGEMENT (SPLITS) ]
  Ctrl + b  v         Split vertically (side by side, Vim-like)
  Ctrl + b  s         Split horizontally (stacked, Vim-like)
  Ctrl + b  Arrow     Move focus to adjacent pane (Up, Down, Left, Right)
  Ctrl + b  z         Zoom toggle (fullscreen current pane / restore)
  Ctrl + b  x         Kill / close current pane
  Ctrl + b  q         Display pane indexes (press number to jump)
  Ctrl + b  Space     Cycle through built-in pane layouts

[ 4. SCROLL & COPY MODE ]
  Ctrl + b  [         Enter scrollback / copy mode (PageUp/Down, Arrows)
  q                   Exit scroll mode

[ 5. COMMAND LINE & ALIASES ]
  tm                  Interactive Tmux session manager
  tm -h / --help      Show this cheatsheet
  tmux ls             List active sessions
  tmux attach -t <S>  Attach to session <S>
  tmux kill-sess -t <S> Kill session <S>
================================================================================
"""
    print(cheatsheet_text)


def main():
    if len(sys.argv) > 1:
        arg = sys.argv[1].lower()
        if arg in ("-h", "--help", "help"):
            print_cheatsheet()
            sys.exit(0)

    if shutil.which(TMUX_BIN) is None:
        sys.stderr.write(f"Error: '{TMUX_BIN}' executable not found or not in PATH.\n")
        sys.exit(1)

    while True:
        sessions = get_sessions()
        count = len(sessions)

        # Render Header (Fixed 42-character width)
        print("==========================================")
        title = f"Tmux Sessions ({count})"
        pad_left = 11
        pad_right = 42 - len(title) - pad_left
        if pad_right < 0:
            pad_right = 0
        header_line = (" " * pad_left) + title + (" " * pad_right)
        print(header_line)
        print("==========================================")

        # Render Sessions
        if count == 0:
            print("   No active sessions")
        else:
            for idx, (display_text, _) in enumerate(sessions, start=1):
                if idx < 10:
                    print(f"   {idx}) {display_text}")
                else:
                    print(f"  {idx}) {display_text}")

        # Render Action Menu
        print("  ----------------------------------------")
        print("   c)   Create new session")
        print("   r)   Rename session")
        print("   d)   Delete session")
        print("   q)   Quit")
        print("==========================================")

        # Construct Prompt string without inline ternaries
        if count == 0:
            prompt_str = "Select session (c: create, q: quit): "
        else:
            if count == 1:
                prompt_str = "Select session (1-1, c: create, r: rename, d: delete, q: quit): "
            else:
                prompt_str = f"Select session (1-{count}, c: create, r: rename, d: delete, q: quit): "

        choice = read_selection(count, prompt_str)

        # Evaluate Selection
        if choice in ["q", "quit", "exit"]:
            break

        if not choice:
            continue

        if choice == "c":
            try:
                new_name = input("Enter new session name (leave blank for auto-generated): ").strip()
            except (KeyboardInterrupt, EOFError):
                print()
                continue
            if not new_name:
                subprocess.run(f"{TMUX_BIN} new-session", shell=True, check=False)
            else:
                if " " in new_name or ":" in new_name or "." in new_name:
                    print("Error: Session name cannot contain spaces, colons (:), or dots (.).")
                    time.sleep(1)
                else:
                    subprocess.run(f'{TMUX_BIN} new-session -A -s "{new_name}"', shell=True, check=False)
        elif choice == "r":
            if count == 0:
                print("No sessions available to rename.")
                time.sleep(1)
                continue
            try:
                ren_input = input(f"Enter session number to rename (1-{count}): ").strip()
            except (KeyboardInterrupt, EOFError):
                print()
                continue
            if ren_input.isdigit():
                target_idx = int(ren_input)
                if 1 <= target_idx <= count:
                    old_name = sessions[target_idx - 1][1]
                    try:
                        new_name = input(f"Enter new name for session '{old_name}': ").strip()
                    except (KeyboardInterrupt, EOFError):
                        print()
                        continue
                    if not new_name:
                        print("Rename cancelled (empty name).")
                        time.sleep(1)
                    else:
                        if " " in new_name or ":" in new_name or "." in new_name:
                            print("Error: Session name cannot contain spaces, colons (:), or dots (.).")
                            time.sleep(1)
                        else:
                            if run_rename(old_name, new_name):
                                print(f"Session '{old_name}' renamed to '{new_name}'.")
                            else:
                                print(f"Failed to rename session '{old_name}'.")
                            time.sleep(1)
                else:
                    print(f"Invalid session number: {target_idx}")
                    time.sleep(1)
            else:
                print(f"Invalid session number: {ren_input}")
                time.sleep(1)
        elif choice == "d":
            if count == 0:
                print("No sessions available to delete.")
                time.sleep(1)
                continue
            try:
                del_input = input(f"Enter session number to delete (1-{count}): ").strip()
            except (KeyboardInterrupt, EOFError):
                print()
                continue
            if del_input.isdigit():
                target_idx = int(del_input)
                if 1 <= target_idx <= count:
                    target_name = sessions[target_idx - 1][1]
                    run_delete(target_name)
                    print(f"Session '{target_name}' deleted.")
                    time.sleep(1)
                else:
                    print(f"Invalid session number: {target_idx}")
                    time.sleep(1)
            else:
                print(f"Invalid session number: {del_input}")
                time.sleep(1)
        elif choice.isdigit():
            target_idx = int(choice)
            if 1 <= target_idx <= count:
                target_name = sessions[target_idx - 1][1]
                subprocess.run(f'{TMUX_BIN} attach-session -t "{target_name}"', shell=True, check=False)
            else:
                print(f"Invalid session number: {choice}")
                time.sleep(1)
        else:
            print(f"Invalid option: '{choice}'")
            time.sleep(1)


if __name__ == "__main__":
    main()
