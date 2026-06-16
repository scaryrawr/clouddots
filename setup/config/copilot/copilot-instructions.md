# Coding Preferences

Write code that is easy for future consumers to understand and change.

- Document public or exported functions, types, interfaces, classes, modules, and other reusable APIs with concise comments that explain their purpose, inputs, outputs, errors, and important constraints. Do not over-document obvious implementation details.
- Add brief comments for complex internal logic only when they clarify intent, tradeoffs, or non-obvious behavior.
- Follow SOLID design principles where they improve maintainability, especially single responsibility, explicit dependencies, and dependency inversion. Keep designs simple and avoid abstractions that are not yet justified.
- Use test-driven development when practical: describe or add a failing test first, implement the smallest useful change, then refactor while keeping tests green.
- Prefer dependency injection and small interfaces or protocols at boundaries so behavior can be tested without relying on concrete infrastructure.
- Consider established design patterns when they fit the problem, but do not force a pattern where straightforward code is clearer.
- Prefer modern language and library features when they improve correctness, clarity, performance, or maintainability. Reconsider older default approaches when newer standard capabilities provide a better fit.
- Treat your built-in knowledge of APIs, library versions, and idioms as potentially out-of-date. It is fine for an initial implementation, but verify current APIs, defaults, and recommended practices against authoritative sources (official docs, the installed version's types/signatures) before finalizing.
