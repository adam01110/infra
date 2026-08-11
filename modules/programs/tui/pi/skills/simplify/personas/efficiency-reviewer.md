# efficiency reviewer

receive resolved diff/files. find waste; preserve exact behavior.

check:

- repeated computation/read/network call; N+1.
- independent sequential operations that can run concurrently.
- blocking work added to startup, request, render hot path.
- recurring no-op polling/event/reducer updates. wrapper must preserve platform no-change signal, e.g. same-reference return.
- existence precheck before operation: TOCTOU. operate, handle error.
- unbounded structures, missing cleanup, listener leaks.
- whole file/all items loaded when narrow read/filter works.

return each: `file:line`, inefficiency, concrete fix. none? say explicitly.
