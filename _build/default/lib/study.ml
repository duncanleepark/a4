(** A flashcard's question and answer. *)
type card = { question : string; answer : string }

(** The side of the current card that is showing. *)
type side = Question | Answer

(** The current card is the head of [remaining], when it is nonempty. *)
type t = { remaining : card list; finished : card list; side : side }

(** [init csv] starts a round from headerless CSV with a question and answer
    on each row. *)
let init csv =
  let rows = Csv.input_all (Csv.of_string csv) in
  let remaining =
    List.map
      (function
        | [ question; answer ] -> { question; answer }
        | _ -> invalid_arg "Study.init: expected two columns per card")
      rows
  in
  { remaining; finished = []; side = Question }

(** [num_remaining state] counts cards left to study, including the current card. *)
let num_remaining state = List.length state.remaining

(** [num_finished state] counts cards already studied. *)
let num_finished state = List.length state.finished

(** [text state] is the text shown on the current card, or a completion message. *)
let text state =
  match state.remaining, state.side with
  | [], _ -> "Congrats!"
  | card :: _, Question -> card.question
  | card :: _, Answer -> card.answer

(** [label state] identifies the current side, or indicates completion. *)
let label state =
  match state.remaining, state.side with
  | [], _ -> "Complete"
  | _, Question -> "Question"
  | _, Answer -> "Answer"

(** [flip state] switches the side of the current card.
    @raise Invalid_argument if the round is complete. *)
let flip state =
  match state.remaining with
  | [] -> invalid_arg "Study.flip: no remaining cards"
  | _ ->
      let side = match state.side with Question -> Answer | Answer -> Question in
      { state with side }

(** [next state] moves the current card to the finished pile and shows the
    next question, if any.
    @raise Invalid_argument if the round is complete. *)
let next state =
  match state.remaining with
  | [] -> invalid_arg "Study.next: no remaining cards"
  | card :: remaining ->
      { remaining; finished = card :: state.finished; side = Question }

let () = Random.self_init ()

(** [restart state] restores and shuffles all cards for a new round. *)
let restart state =
  let cards = BatList.shuffle (state.remaining @ state.finished) in
  { remaining = cards; finished = []; side = Question }
