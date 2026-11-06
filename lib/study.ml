(** A flashcard's question and answer. *)
type card = { question : string; answer : string }

(** The side of the current card that is showing. *)
type side = Question | Answer

(** The current card is the head of [remaining], when it is nonempty. *)
type t = { remaining : card list; finished : card list; side : side }

(** [init cards] starts a round with [cards] in the given order.
    @raise Invalid_argument if [cards] is empty. *)
let init cards =
  match cards with
  | [] -> invalid_arg "Study.init: empty deck"
  | _ -> { remaining = cards; finished = []; side = Question }

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
  let cards = Array.of_list (state.remaining @ state.finished) in
  for i = Array.length cards - 1 downto 1 do
    let j = Random.int (i + 1) in
    let card = cards.(i) in
    cards.(i) <- cards.(j);
    cards.(j) <- card
  done;
  { remaining = Array.to_list cards; finished = []; side = Question }
