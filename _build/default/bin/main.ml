open Lwt
open Js_of_ocaml
open Js_of_ocaml_lwt
open A4

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

(** [picker id] returns the input element with the given ID.
    @raise Invalid_argument if no such input exists. *)
let picker (id : string) : Dom_html.inputElement Js.t =
  Option.get (Dom_html.getElementById_coerce id Dom_html.CoerceTo.input)

(** [choose_file picker] waits until a file is selected. *)
let rec choose_file (picker : Dom_html.inputElement Js.t) : File.file Js.t Lwt.t =
  let%lwt _ = Lwt_js_events.change picker in
  match Js.Opt.to_option (picker##.files##item 0) with
  | None -> choose_file picker
  | Some file -> Lwt.return file

(** [render state] displays the current card and its side. *)
let render (state : Study.t) : unit =
  set_text (paragraph "card-text" :> Dom_html.element Js.t) (Study.text state);
  set_text (paragraph "card-side" :> Dom_html.element Js.t) (Study.label state);
  set_text (paragraph "status" :> Dom_html.element Js.t)
    (Printf.sprintf "%d remaining, %d finished"
       (Study.num_remaining state) (Study.num_finished state));
  let complete = Study.num_remaining state = 0 in
  (button "flip")##.disabled := Js.bool complete;
  (button "next")##.disabled := Js.bool complete;
  (button "restart")##.disabled := Js._false

(** [on_click button handler] attaches a click event handler to the given HTML
    button. *)
let on_click (button : Dom_html.buttonElement Js.t) (handler : unit -> unit) :
    unit =
  Lwt.async (fun () ->
      Lwt_js_events.clicks button (fun _event _loop ->
          handler ();
          Lwt.return ()))

let main () : unit Lwt.t =
  let deck_picker = picker "deck-file" in
  deck_picker##.disabled := Js._false;
  let%lwt file = choose_file deck_picker in
  deck_picker##.disabled := Js._true;
  set_text (paragraph "deck-name" :> Dom_html.element Js.t)
    (Js.to_string file##.name);
  set_text (paragraph "status" :> Dom_html.element Js.t) "Reading your deck…";
  let%lwt contents = File.readAsText file in
  let state = ref (Study.init (Js.to_string contents)) in
  render !state;
  on_click (button "flip") (fun () ->
      state := Study.flip !state;
      render !state);
  on_click (button "next") (fun () ->
      state := Study.next !state;
      render !state);
  on_click (button "restart") (fun () ->
      state := Study.restart !state;
      render !state);
  Lwt.return ()

let () = Lwt.async main
