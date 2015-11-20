Progetto Linguaggi di Programmazione:
Costruzione sistema OOL, Object-Oriented Lisp

------------------
Predicati pubblici
------------------
- define-class (class-name parent slot-value)
	Definiti il nome della classe (class-name), la classe genitore (parent) e gli eventuali campi che caratterizzano la classe (slot-value),
	viene creata la classe inserendola in una hash table, dove il nome della classe è la chiave mentre la association list contenente
	i campi della classe è il valore.
	Si ha errore quando: 	- class-name non è un simbolo
				- parent non è un simbolo
				- class-name e parent sono uguali
				- la class parent non esiste
	Nel caso in cui si definisce una classe con il nome di una classe già definita, questa viene cancellata e quindi sostituita.

- new (class-name slot-value)
	Definiti il nome della classe già esistente (class-name) e gli eventuali campi (slot-value) che già fanno parte della classe principale,
	viene creata l'istanza della classe scelta tramite la realizzazione di una association list contenente tutti i campi della classe selezionata
	e di tutte le eventuali classi genitore.
	Si ha errore quando:	- class-name non è un simbolo
	Definiti i casi:	- slot-value e parent di class-name vuoti
				- slot-value vuoto e parent presente
				- parent vuoto e slot-value presenti
				- presenti sia il parent che i slot-value

- get-slot (instance slot-name)
	Data l'istanza (instance) e il nome dello slot interessato (slot-name), viene restituito il valore associato allo slot.
	Si ha errore quando:	- l'istanza non è corretta
				- slot-name non è un simbolo
				- lo slot non è presente nell'istanza

------------------
Predicati privati
------------------
- create-slot (class-name slot-value)
	Richiamata dalla define-class, ricevendo il nome della classe (class-name) e la lista degli slot della classe (slot-value), viene creata la 
	association list in cui ogni elemento ha come chiave il nome dello slot e come valore il contenuto dello slot; nel caso in cui lo slot 
	contiene un metodo, viene richiamata la funzione process-method che andrà a creare la funzione rinominata con il nome dello slot associato 
	al metodo.
	Si ha errore quando: 	- il nome dello slot non è un simbolo
				- sono presenti due slot con lo stesso nome
	In caso di errore, viene eliminata la classe dalla hash table.

- check-parent (class-name list)
	Dato che la classe indicata (class-name) contiene classi parenti, viene creata la association list (list) con tutti gli slot presenti nelle
	classi antenate; una volta creata la lista, vengono rimossi eventuali slot duplicati a partire dal fondo, cioè quelli più "vecchi".

- create-instance (class-name slot-value list)
	Richiamata da new, crea l'istanza producendo una association list ottenuta dall'unione degli slot appertenenti già alla classe indicata 
	(class-name) con la lista degli eventuali slot modificati (slot-value) richiamando la new; nel caso in cui viene ridefinito un metodo, viene
	richiamata la funzione process-method, che penserà a ricreare la funzione con il nome dello slot indicato; una volta creata la lista, vengono 
	rimossi gli slot duplicati partendo dal fondo della lista, cioè quelli più "vecchi".
	Si ha errore quando: 	- lo slot non è presente nella classe per cui si crea l'istanza

- process-method (method-name)
	Definisce una funzione, rinominata con il nome dello slot (method-name) che possiede il metodo, avente come corpo una funzione lambda, creata al
	momento della chiamata della funzione, dove gli argomenti sono this più gli eventuali argomenti dichiarati nel metodo dello slot e il corpo è 
	estratto dallo slot escludendo gli argomenti.









