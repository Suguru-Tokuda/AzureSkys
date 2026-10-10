# Swift formatting

Use four spaces for indentation and keep lines within 120 columns where practical.
Separate logical steps with a blank line: validation, preparation, side effects,
and the returned result. Keep related property declarations and assignments together.
Use a blank line between switch branches with statement bodies.

Expand control-flow blocks containing work (`if`, `for`, `do`/`catch`, `defer`,
and `Task`) onto multiple lines. A short guard that simply returns can stay on
one line. Keep simple expression closures compact. When an argument list spans
multiple lines, put each argument on its own line and place the closing parenthesis
on its own line. Preserve existing import order and explicit returns.

The repository's `.swift-format` captures the mechanical layout settings and
disables unrelated refactoring rules. Run it with the formatter bundled in Xcode:

```sh
xcrun swift-format format --in-place --recursive AzureSkys AzureSkysTests AzureSkysUITests
```

The formatter preserves blank lines; use judgment to group logical steps when
writing new code.
