open Lwt
open Js_of_ocaml

let main () : unit Lwt.t =
  let card = Dom_html.getElementById "card-text" in
  card##.textContent := Js.some (Js.string "How many times have the Bills won the Super Bowl?");
  Lwt.return ()

let () = Lwt.async main
