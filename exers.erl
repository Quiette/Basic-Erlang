%% Main function is main/1 run in terminal via "escript exers.erl 1"

-module (exers).
-import (math, [pow/2]).
-import (string, [concat/2]).
-import (lists, [merge/2, seq/2, split/2]).
-import (calendar, [day_of_the_week/1, valid_date/1]).
-export([main/1]).


divisors(N) -> [I ||
       I <- seq(2,N div 2),
        N rem I == 0 ].

primes(N) -> [I ||
       I <- seq(2,N),
        divisors(I) == [] ].

pythagorean(N) -> [{A,B,C} ||
    B <- seq(1,N),
    A <- seq(1,B),
    C <- seq(1,N), 
    A < B,
    pow(C,2) == pow(A,2) + pow(B,2)].

% join already exists in list Module
join (_, List) when List == [] -> "";
join (_, [X | [] ]) -> X;
join (S, [X | Y ]) -> concat(X, S) ++ join(S,Y).

% Merge already exists in list module
mergeSort([]) -> [];
mergeSort([A| [] ]) -> [A];
mergeSort(List) -> 
        Halfway = length(List) div 2,
        Splitting = split(Halfway,List),
        FirstHalf = mergeSort(element(1,Splitting)),
        SecondHalf = mergeSort(element(2,Splitting)),
        merge(FirstHalf,SecondHalf).

isFriday(Date = {_, _, _}) ->
        day_of_the_week(Date) == 5.

isPrimeDate({_, _, D}) ->
         divisors(D) == [].

main(X) ->
        X = X,  %% Added to avoid printing error/warning about unused variable
        main().

main() ->
        io:fwrite("~p ~n", [divisors(30)]),
        io:fwrite("~p ~n", [divisors(64)]),
        io:fwrite("~p ~n", [divisors(127)]),
        io:fwrite("~p ~n", [primes(7)]),
        io:fwrite("~p ~n", [primes(100)]),
        io:fwrite("~p ~n", [pythagorean(10)]),
        io:fwrite("~p ~n", [pythagorean(30)]),
        io:fwrite("~p ~n", [join(",", ["One", "Two", "Three"])]),
        io:fwrite("~p ~n", [join("+", ["1", "2", "3"])]),
        io:fwrite("~p ~n", [join("X", ["abc"])]),
        io:fwrite("~p ~n", [join("X", [])]),
        io:fwrite("~p ~n", [mergeSort([1,9,3,2,7,6,4,8,5])]),
        io:fwrite("~p ~n", [mergeSort([6,2,4,8,9,5,3,1,7,10])]),
        io:fwrite("~p ~n", [mergeSort([])]),
        io:fwrite("~p ~n", [mergeSort([4])]),
        io:fwrite("~p ~n", [mergeSort("The quick brown fox jumps over the lazy dog.")]),
        io:fwrite("~p ~n", [isFriday({2018,5,17})]),
        io:fwrite("~p ~n", [isFriday({2018,5,18})]),
        io:fwrite("~p ~n", [isPrimeDate({2018,5,13})]),
        io:fwrite("~p ~n", [isPrimeDate({2018,5,14})]),
        io:fwrite("~p ~n", [isPrimeDate({2018,6,23})])
        .

