%   312 Civilization project
%   Author: Nafisa 18769142 d3w9a
%           John   52043122 k0b9
%   

%=============VARIABLE===============================
% Global variable setter
setFood(X) :- nb_setval(food, X).
setGold(X) :- nb_setval(gold, X).
setLand(X) :- nb_setval(land, X).
setRep(X) :- nb_setval(reputation, X).
setSol(X) :- nb_setval(soldiers, X).
% Global variable getter
getFood(X) :- nb_getval(food, X).
getGold(X) :- nb_getval(gold, X).
getLand(X) :- nb_getval(land, X).
getRep(X) :- nb_getval(reputation, X).
getSol(X) :- nb_getval(soldiers, X).
% Global variable setter given a list
setResources([A,B,C,D,E]) :-
    setFood(A), setGold(B), setLand(C), setRep(D), setSol(E).
% Global variable getter to a list
getResources([A,B,C,D,E]) :-
    getFood(A), getGold(B), getLand(C), getRep(D), getSol(E).
%=============VARIABLE===============================

%readFromUser(L) is true if L contains user's input as a List. 
readFromUser(L) :-
    read_line_to_codes(user_input, Cs), atom_codes(A, Cs), atomic_list_concat(L, ' ' , A).

%=============DICTIONARY===========================
%getDictionaru(H,L,P) is true dictionary L is in the list A with a probability of P.
getDictionary([], H, _) :-
    dictionary(H,0.0).
getDictionary([H|_], H, P) :-
    dictionary(H, P).
getDictionary([_|T], A, P) :-
    getDictionary(T, A, P).

%Dictionary of keywords
dictionary(battle, 0.5). 
dictionary(fight, 0.5). 
dictionary(yield, 0.5).
dictionary(request, 0.5).
dictionary(continue, 0.5).
dictionary(permit, 0.5).
dictionary(prohibit, 0.5).
dictionary(persia, 0.5).
dictionary(portugal, 0.5).
dictionary(accept, 0.5).
dictionary(reject, 0.5).
dictionary(again,_).        %Special dictionary word for redoing the stage
dictionary(end,_).          %Special dictionary word for ending the stage
dictionary(invalid,0.0).    %Special dictionary word for user's invalid input

%=============DICTIONARY===========================


%=============PRINTING RESOURCES===========================
%print_resources(A,B) is true if A is a list.
%This is used to print current values of resources.
print_resources([], _).
print_resources([Resource | RT], [Value | VT]) :-
	format('~w: ~w, ', [Resource, Value]),
	print_resources(RT, VT).

%Helper function to print resources
fetchResources :-
	getResources(X),
	print_resources(['Food', 'Gold', 'Land', 'Reputation', 'Soldiers'], X).

%Helper function2 to print resources
print :-
    write_ln(" "), write_ln("CURRENT RESOURCES:"),
    fetchResources, write_ln(" "), write_ln(" ").

%=============PRINTING RESOURCES===========================


%=============CONDITION CHECKER==========================
%continue(A) is true if A is a positive value.
continue([A,B,C,D,E]) :-
    A>0. 
%=============CONDITION CHECKER==========================

%=============GAME===============================================
%   Game goes on sequentially from stageA to stageE.
%   

%Start of the game
start :-
    setResources([8,20,35,5,15]),       %Setting the initial resources for the game
    write("Welcome to CIVILIZATION! You start out with a given number of"),
    write(" resources. Try to finish the game before any of your resources run out!"),
    write_ln(" "), stageA.              %Start stageA.

stageA :-
    print, getResources(A), continue(A),
    write_ln("Welcome, you are a new king of a small country in China. Try to survive till the end!"),
    write_ln("The Mongolians come marching to invade your land. Will you prepare for fight or yield?"),
    readFromUser(Q), getDictionary(Q,H,P),
    getRep(R), getSol(S), getLand(L),
    ( H = fight->
        (maybe(P) -> 
            write_ln("You successfully launch a counteroffensive but suffer high casualties."), 
            S1 is S-4, setSol(S1), stageB ; 
            write_ln("You failed to rally your forces in time and lose substantial amount of land."), 
            R1 is R-3, setRep(R1), L1 is L-5, setLand(L1), stageB) ;

      H = yield->
        write_ln("You have no faith in your forces and choose to yield a substantial tract of land to the Mongolians."), 
        write_ln("There goes your reputation as a leader"), 
        R1 is R-7, setRep(R1), L1 is L-8, setLand(L1), stageB ;
      H = invalid->
        write_ln("INVALID CHOICE, REDOING THE STAGE"), stageA ).

stageB :-  
    print, getResources(A), (continue(A) ->
    write_ln("The disappointing harvest this year forces you into a food shortage."),
    write_ln("You can request food from the villagers, risking your reputation and losing gold, "),
    write_ln("or you can continue with lowered food supplies."),

    readFromUser(Q), getDictionary(Q,H,P),
    getRep(R), getGold(G), getFood(F),
    ( H = request ->
        (maybe(P) -> 
            write_ln("You request food from village elders who scorn your impertinence."),
            write_ln("You lose some reputation and gold but gain a sack of potatoes."),
            R1 is R-2, setRep(R1), G1 is G-15, setGold(G1), F1 is F+6, setFood(F1), stageC ;

            write_ln("You request food from the village elders who comply completely out"),
            write_ln("fear of retaliation. You gain five sacks of rice."),
            R1 is R-2, setRep(R1), G1 is G-8, setGold(G1), F1 is F+9, setFood(F1), stageC) ;
       H = continue ->
            write_ln("You dismiss the food shortage as an unimportant concern. "),
            write_ln("You continue with lowered food supplies."),
            F1 is F-4, setFood(F1), stageC ;
       H = invalid ->
        write_ln("INVALID CHOICE, REDOING THE STAGE"), stageB ) 
    ; stageEnd).
 
stageC :-  
    print, getResources(A), (continue(A) ->
    write_ln("Fall arrives and brings with it the Festival of Fertility."),
    write_ln("You can permit your soldiers to participate in the celebrations or prohibit them."),

    readFromUser(Q), getDictionary(Q,H,P),
    getGold(G), getSol(S), 
       (H = permit->
            write_ln("You permit your soldiers to participate in the celebrations."),
            write_ln("They spend your gold recklessly and harm your reputation"),
            G1 is G-13, setGold(G1), stageD ;
       H = prohibit->
        (maybe(P) -> 
            write_ln("You prohibit your soldiers from participating in the celebrations."),
            write_ln("Some grumble and quit your army."),
            S1 is S-2, setSol(S1), stageD ;

            write_ln("You prohibit your soldiers from participating in the celebrations."),
            write_ln("This doesn't affect them as they wre antisocial to begin with."),
            stageE) ;
       H = invalid ->
        write_ln("INVALID CHOICE, REDOING THE STAGE"), stageC ) 
    ; stageEnd).


stageD :- 
    print, getResources(A), (continue(A) ->
    write_ln("You decide to expland the borders of your empire. On the East is the heavily"),
    write_ln("fortified but mineral-rich land of Persia and on the North is the populated "),
    write_ln("land of Portugal, center of commerce. Will you march towards Persia or Portugal?"),

    readFromUser(Q), getDictionary(Q,H,P),
    getRep(R), getGold(G), getLand(L), getFood(F), getSol(S), 
    ( H = portugal->
        (maybe(P) -> 
            write_ln("You choose to march towards Portugal, your army leaves a trail of "),
            write_ln("looted towns and burned villages behind them. "),
            G1 is G+17, setGold(G1), R1 is R-5, setRep(R1), L1 is L+9, setLand(L1), stageE ;

            write_ln("You choose to march towards Portugal. You overexerted your soldiers, "),
            write_ln("drill into your remaining food supply, and lose reputation for being overambitious."),
            R1 is R-3, setRep(R1), S1 is S-2, setSol(S1), F1 is F-4, setFood(F1), stageE) ;
       H = persia->
            write_ln("You choose to march towards Persia. Unfortunately, the moment you left"),
            write_ln("your land, the Mongolians re-invaded."),
            L1 is L-6, setLand(L1), stageE ;
       H = invalid ->
        write_ln("INVALID CHOICE, REDOING THE STAGE"), stageD ) 
    ; stageEnd).

stageE :- 
    print, getResources(A), (continue(A) ->
    write_ln("An architect approaches you with a proposal to build a temple in your name."),
    write_ln("She asks for a lump sum payment of 20 gold for the blueprints. Will you accept"),
    write_ln("her proposal and pay for blueprints, or reject her offer and save your money for food?"),

    readFromUser(Q), getDictionary(Q,H,P),
    getRep(R), getGold(G), getFood(F), getSol(S), 
    ( H = accept->
        (maybe(P) -> 
            write_ln("Your hungry soldiers watch in amazement as their leader spends valuable"),
            write_ln("gold to erect a monument to narcissism. Your reputation plummets and "),
            write_ln("your soldiers quit in disgust."),
            R1 is R-8, setRep(R1), G1 is G-20, setGold(G1), S1 is S-8, setSol(S1), stageF ;

            write_ln("You pay the architect for blueprints and spend the rest of your gold on"),
            write_ln("construction workers. The locals are impressed with the result and you "),
            write_ln("gain pride and reputation."),
            R1 is R+8, setRep(R1), setGold(1), stageF) ;
       H = reject->
            write_ln("You reject the architect's offer and spend your gold on food instead. Wise decision"),
            F1 is F+10, setFood(F1), G1 is G-5, setGold(G1), stageF ;
       H = invalid ->
        write_ln("INVALID CHOICE, REDOING THE STAGE"), stageE ) 
    ; stageEnd).


%Final stage where user wins.
stageF :-
    print,
    write_ln("You have finished the game! Congratulations").

%Ending stage if user fails.
stageEnd :-
    write_ln("You are out of resources! You lost! Try again or end?"),
    readFromUser(L), getDictionary(L,H,_),
    ( H = again -> stageA ;
      H = end -> true).

