---
name: lavish
description: Open interactive HTML visual artifacts, plans, comparisons, architecture diagrams, and review boards in the browser using lavish-axi.
user-invocable: true
---

# lavish

Use `lavish-axi` when the captain asks for `/lavish` or when a complex plan, comparison, architecture diagram, or `/bearings` board is clearer as an interactive visual page:

1. Run `lavish-axi design` and `lavish-axi playbook <diagram|table|comparison|plan|code|input|explanation|slides>` to check current layout and component guidance.
2. Author the HTML file under `.lavish/<name>.html`.
3. Launch the local review session with `lavish-axi .lavish/<name>.html`.
4. Poll for annotations and feedback using `lavish-axi poll .lavish/<name>.html`.
