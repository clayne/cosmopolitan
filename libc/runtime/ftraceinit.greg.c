/*-*- mode:c;indent-tabs-mode:nil;c-basic-offset:2;tab-width:8;coding:utf-8 -*-│
│ vi: set et ft=c ts=2 sts=2 sw=2 fenc=utf-8                               :vi │
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2021 Justine Alexandra Roberts Tunney                              │
│                                                                              │
│ Permission to use, copy, modify, and/or distribute this software for         │
│ any purpose with or without fee is hereby granted, provided that the         │
│ above copyright notice and this permission notice appear in all copies.      │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL                │
│ WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED                │
│ WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE             │
│ AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         │
│ DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR        │
│ PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER               │
│ TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR             │
│ PERFORMANCE OF THIS SOFTWARE.                                                │
╚─────────────────────────────────────────────────────────────────────────────*/
#include "libc/dce.h"
#include "libc/runtime/internal.h"
#include "libc/runtime/runtime.h"
#include "libc/runtime/symbols.internal.h"
#include "libc/str/str.h"
#include "libc/thread/tls.h"

__static_yoink("zipos");

/**
 * Enables plaintext function tracing if `--ftrace` flag is passed.
 *
 * The `--ftrace` CLI arg is removed before main() is called. This code
 * is intended for diagnostic purposes and assumes binaries are
 * trustworthy and stack isn't corrupted. Logging plain text allows
 * program structure to easily be visualized and hotspots identified w/
 * `sed | sort | uniq -c | sort`. A compressed trace can be made by
 * appending `--ftrace 2>&1 | gzip -4 >trace.gz` to the CLI arguments.
 *
 * @see libc/runtime/_init.S for documentation
 */
textstartup int ftrace_init(void) {
  if (IsModeDbg() || strace_enabled(0) > 0) {
    GetSymbolTable();
  }
  if (__intercept_flag(&__argc, __argv, "--ftrace")) {
    ftrace_install();
    ftrace_enabled(+1);
  }
  return __argc;
}
