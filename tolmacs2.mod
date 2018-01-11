
# valtozok, dontesek

set nyelvek;
set tolmacsok;
set konferenciak;
param tolmacsNyelv{tolmacsok, nyelvek} binary;
param tolmacsUtaz{tolmacsok} integer;
param tolmacsPenz{tolmacsok} integer;
param tolmacsKm{tolmacsok} integer;
param konfNyelv{konferenciak, nyelvek} binary;
param konfKm{konferenciak} integer;
param konfPenz{konferenciak} integer;
set het;
param konfIdo{konferenciak, het} binary;

param nyelvekN:= card(nyelvek);

var kiHova{tolmacsok, konferenciak}, binary;
var kuldunkE{konferenciak}, binary;
var lefedettNyelv{konferenciak, nyelvek}, binary;
var foglalt{tolmacsok, het}, binary;

# korlatozasok

# BUNTI: azon napok, amikor a tolmacs foglalt
s.t. foglaltVezetes{t in tolmacsok, h in het}:
	foglalt[t,h] = sum{k in konferenciak:  konfIdo[k,h]} kiHova[t,k];

# BUNTI: ha egy napon mar foglalt a tolmacs, aznap nem mehet masikra
s.t. nemMegyMasikraHaFoglalt{t in tolmacsok, k in konferenciak}:
	kiHova[t,k] <= sum{h in het} konfIdo[k,h] * foglalt[t,h];

# a tolmacs nem utazik messzebb, mint amennyit hajlando
s.t. nemUtazikMesszebb{t in tolmacsok, k in konferenciak}:
	kiHova[t,k] <= tolmacsUtaz[t] / konfKm[k];

# kuldunk-e tolmacsot egyaltalan az adott konferenciara
s.t. kuldunkETolmacsot{k in konferenciak}:
	kuldunkE[k] = sum{t in tolmacsok} kiHova[t,k];

# a lefedett nyelvek szamitasa
s.t. fedettNyelvek{k in konferenciak, n in nyelvek}:
	lefedettNyelv[k,n] = 1 - (konfNyelv[k,n] - sum{t in tolmacsok: tolmacsNyelv[t,n] * konfNyelv[k,n]} kiHova[t,k]);
 
# ahol nincs minden nyelv lefedve, oda ne is kuldjunk tolmacsot
s.t. aholNemFedunkLeMindentOdaNeMenjenSenki{k in konferenciak}:
	sum{t in tolmacsok}kiHova[t,k] <= sum{n in nyelvek} lefedettNyelv[k,n] / nyelvekN;

# celfuggveny
maximize profit : sum{k in konferenciak} (kuldunkE[k] * konfPenz[k]) - (sum{t in tolmacsok, k in konferenciak} kiHova[t,k] * tolmacsPenz[t]);

solve;

# out

printf "\n\n";

printf "Osszes profit: %d", profit;

printf "\n\n";
for{k in konferenciak: sum{t in tolmacsok} kiHova[t,k] >= 1}
{
	printf "%s konferencia:\n",k;
	
	for{t in tolmacsok: kiHova[t,k] = 1}
	{
		printf "\t%s - %d Ft\n", t, tolmacsPenz[t];
	}
	printf "\t---\n";
	printf "\tbevtel: %d Ft\n", konfPenz[k];
	printf "\tkifizetes: %d Ft\n", sum{t in tolmacsok} kiHova[t,k] * tolmacsPenz[t];
	printf "\tprofit: %d Ft\n", konfPenz[k] - sum{t in tolmacsok} kiHova[t,k] * tolmacsPenz[t];
	printf "\n";
}
printf "\n";

# melyik konferenciara nem kuldtunk senkit
for{k in konferenciak: sum{t in tolmacsok} kiHova[t,k]=0}
{
	printf "%s konferenciara nem kuldtunk senkit.\n", k;
}

printf "\n";

# akiket nem kultunk konferenciara
for{t in tolmacsok: sum{k in konferenciak} kiHova[t,k]=0}
{
	printf "%st nem kuldtuk konferenciara.\n", t;
}

printf "\n\n\n";

end;