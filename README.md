# Flip Side

Flip Side is a browser-based flashcard app written in OCaml and compiled to JavaScript with js_of_ocaml.

## Build and run

Install the project dependencies with opam, including `dune`, `js_of_ocaml`, `js_of_ocaml-ppx`, `js_of_ocaml-lwt`, `lwt_ppx`, `batteries`, and `csv`. Then, from the project directory, run:

```sh
dune build public/index.html
```

Open `_build/default/public/index.html` in a web browser and choose a CSV deck using the file picker. Reload the page to choose a different deck.

## Deck format

Decks are CSV files with no header. Each row contains exactly two columns: the question followed by the answer. Quote a field containing a comma, quotation mark, or line break; represent a quotation mark inside a quoted field with two quotation marks (`""`). A quoted answer may span multiple lines. Decks must contain at least one card.

The `decks` directory contains sample decks. `special.csv` has exactly three distinct cards and demonstrates commas, quotation marks, and a multiline answer.

## Controls

- **Flip** switches between the question and answer.
- **Next** moves the current card to the finished pile.
- **Restart Terms** shuffles all cards into a new round, including after completion.

When all cards are finished, the app displays “Congrats!” and disables Flip and Next. Restart Terms remains available.
