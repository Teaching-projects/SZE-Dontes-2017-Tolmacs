
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

var kiHova{tolmacsok, konferenciak} binary;
var nemHasznaltNyelv{konferenciak, nyelvek}, binary;
var kuldunke{konferenciak} binary;

# korlatozasok

s.t. egyTolmacsMaxEgyKonferencian{t in tolmacsok}:
	sum{k in konferenciak} kiHova[t,k] <= 1;

s.t. nemMegyTavolabb{t in tolmacsok, k in konferenciak}:
	kiHova[t,k] <= tolmacsUtaz[t] / konfKm[k];

s.t. vanPenzeRa{k in konferenciak}:
	sum{t in tolmacsok} (kiHova[t,k] *  tolmacsPenz[t]) <= konfPenz[k];

#s.t. megvanEMindenNyelv{k in konferenciak}:1k
#	sum{t in tolmacsok} (kiHova[t,k] * sum{n in nyelvek: tolmacsNyelv[t,n] + konfNyelv[k,n] = 2} (tolmacsNyelv[t,n])) >= sum{n in nyelvek} konfNyelv[k,n];

s.t. megVanEMindenNyelv{k in konferenciak, n in nyelvek}:
	nemHasznaltNyelv[k,n] = konfNyelv[k,n] - (sum{t in tolmacsok: tolmacsNyelv[t, n] * konfNyelv[k, n] = 1} kiHova[t,k]);

s.t. kuldunkE{k in konferenciak}:
	kuldunke[k] <= sum{t in tolmacsok} kiHova[t,k];

#s.t. profitSzamolas:
#	profit = sum{k in konferenciak}(kuldunke[k]*konfPenz[k]) -  sum{t in tolmacsok, k in konferenciak} kiHova[t,k] * tolmacsPenz[t];

# celfuggveny
maximize profit: sum{k in konferenciak} (kuldunkE[k] * konfPenz[k]) - sum{t in tolmacsok, k in konferenciak} kiHova[t,k] * tolmacsPenz[t]; 
#minimize kihasznalatlansag: sum{k in konferenciak, n in nyelvek} nemHasznaltNyelv[k,n];
#maximize profit: sum{t in tolmacsok, k in konferenciak} kiHova[t,k] * tolmacsPenz[t];

solve;

# out

printf "\n\n\n";

for{k in konferenciak}
{
	for{n in nyelvek}
	{
		printf " %d", nemHasznaltNyelv[k,n];
	}
	printf "\n";
}

printf "\n\n\n";
printf "Osszes profitunk a konferenciakbol: %d Ft", profit;
printf "\n\n";
for{k in konferenciak: sum{t in tolmacsok} kiHova[t,k] >= 1}
{
	printf "%s konferencia:\n",k;
	
	for{t in tolmacsok: kiHova[t,k] = 1}
	{
		printf "\t%s - %d Ft\n", t, tolmacsPenz[t];
	}
	printf "\t---\n\tossz.: %d Ft\n", sum{t in tolmacsok} kiHova[t,k] * tolmacsPenz[t];
	printf "\n";
}
printf "\n";

for{k in konferenciak: sum{t in tolmacsok} kiHova[t,k]=0}
{
	printf "%s konferenciara nem kuldunk senkit.\n", k;
}

printf "\n";

for{t in tolmacsok: sum{k in konferenciak} kiHova[t,k]=0}
{
	printf "%st nem kuldtuk konferenciara.\n", t;
}

printf "\n\n";

end;