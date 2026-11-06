open Lwt
open Js_of_ocaml
open Js_of_ocaml_lwt

(** [set_text element text] sets the text content of the given HTML element. *)
let set_text (element : Dom_html.element Js.t) (text : string) : unit =
  element##.textContent := Js.some (Js.string text)

(** [paragraph id] returns the HTML paragraph element with the given ID.
    @raise Invalid_argument if no such paragraph exists. *)
let paragraph (id : string) : Dom_html.paragraphElement Js.t =
  Option.get (Dom_html.getElementById_coerce id Dom_html.CoerceTo.p)

(** [button id] returns the HTML button element with the given ID.
    @raise Invalid_argument if no such button exists. *)
let button (id : string) : Dom_html.buttonElement Js.t =
  Option.get (Dom_html.getElementById_coerce id Dom_html.CoerceTo.button)

let main () : unit Lwt.t =
  let card = Dom_html.getElementById "card-text" in
  card##.textContent := Js.some (Js.string "Who is the Buffalo Bills' Quarterback?");
  Lwt.return ()

let () = Lwt.async main
