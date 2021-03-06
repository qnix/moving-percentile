open Printf

let print_csv_header () =
  printf "i,naive100_90,naive300_90,naive1000_90,moving_90,delta,x\n"

let print_csv_state i naive100 naive300 naive1000 state x =
  let open Mv_percentile in
  let m100, _ = Mv_naive_percentile.get naive100 in
  let m300, _ = Mv_naive_percentile.get naive300 in
  let m1000, _ = Mv_naive_percentile.get naive1000 in
  let m = Mv_percentile.get state in
  let delta = state.Mv_percentile.delta in
  printf "%i,%g,%g,%g,%g,%g,%g\n"
    i m100 m300 m1000 m delta x

let process_sample i naive100 naive300 naive1000 state =
  try
    let x = float_of_string (input_line stdin) in
    Mv_percentile.update state x;
    Mv_naive_percentile.update naive100 x;
    Mv_naive_percentile.update naive300 x;
    Mv_naive_percentile.update naive1000 x;
    print_csv_state i naive100 naive300 naive1000 state x;
    Some ()
  with End_of_file ->
    None

let loop () =
  let p = 0.9 in
  let naive100 =
    Mv_naive_percentile.init
      ~window_length:100
      p
  in
  let naive300 =
    Mv_naive_percentile.init
      ~window_length:300
      p
  in
  let naive1000 =
    Mv_naive_percentile.init
      ~window_length:1000
      p
  in
  let state =
    Mv_percentile.init
      ~p
      ()
  in
  let stream =
    Stream.from (fun i ->
        process_sample i naive100 naive300 naive1000 state
      )
  in
  print_csv_header ();
  Stream.iter (fun () -> ()) stream

let main () =
  loop ()

let () = main ()
