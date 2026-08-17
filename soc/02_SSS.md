# Shamir's Secret Sharing (SSS) w KMS – Koncepcja i Architektura

Dokumentacja koncepcyjna wykorzystania algorytmu podziału sekretu Shamira (*Shamir's Secret Sharing*) do zarządzania kluczem głównym (*Master Key*) w mikroserwisie KMS.

---

## 1. Cel Architektoniczny

Zapewnienie maksymalnej izolacji klucza głównego (*Master Key*) poprzez wyeliminowanie jego trwałego przechowywania w kodzie, bazach danych oraz na dyskach twardych. Klucz główny istnieje wyłącznie w pamięci RAM serwisu KMS w trakcie jego działania.

---

## 2. Zasada Działania (Threshold Scheme)

Algorytm opiera się na matematycznej właściwości wielomianów nad ciałami skończonymi. Klucz główny jest dzielony na $N$ unikalnych fragmentów (*shares*), z których do jego rekonstrukcji wymagane jest dostarczenie co najmniej $K$ dowolnych fragmentów ($K \le N$).

* **Próg ($K$):** Minimalna liczba fragmentów wymagana do odtworzenia sekretu (np. $K = 3$).
* **Liczba udziałów ($N$):** Całkowita liczba wygenerowanych fragmentów (np. $N = 5$).
* **Bezpieczeństwo:** Posiadanie mniejszej liczby fragmentów niż $K$ (np. $K-1$) daje kryptograficznie zerową informację o wartości klucza głównego.

---

## 3. Cykl Życia Serwisu KMS

### A. Inicjalizacja (Bootstrapping)

1. Pierwsze uruchomienie serwisu KMS generuje losowy klucz główny (*Master Key*).
2. Algorytm SSS dzieli klucz na $N$ fragmentów przy progu $K$.
3. Fragmenty zostają zwrócone jednorazowo operatorowi/systemowi.
4. Serwis nie zapisuje klucza głównego na dysku.

### B. Stan Zablokowany (Sealed)

1. Po każdym restarcie Poda/kontenera KMS startuje w trybie **Sealed**.
2. Interfejs komunikacyjny aplikacji (np. Unix Domain Socket) pozostaje nieaktywny lub zwraca błąd `503 Service Unavailable`.
3. Operacje kryptograficzne (szyfrowanie/odszyfrowywanie) są całkowicie zablokowane.

### C. Procedura Odblokowania (Unseal)

1. Operatorzy lub odseparowane systemy dostarczają po kolei $K$ fragmentów klucza przez CLI lub dedykowany port administracyjny.
2. Po odebraniu $K$-tego fragmentu KMS rekonstruuje klucz główny bezpośrednio w pamięci RAM.
3. Stan serwisu zmienia się na **Unsealed**.
4. Następuje otwarcie gniazda komunikacyjnego (UDS) dla aplikacji klienckiej.

```text
[ Start Poda / Restart ]
          │
          ▼
   [ Stan: Sealed ] ──(Gniazdo UDS zamknięte / Brak operacji crypto)
          │
          ├─► Wprowadzenie fragmentu 1/3
          ├─► Wprowadzenie fragmentu 2/3
          └─► Wprowadzenie fragmentu 3/3
                  │
                  ▼
   [ Rekonstrukcja w RAM ]
                  │
                  ▼
  [ Stan: Unsealed ] ──(Gniazdo UDS otwarte / Pełna obsługa żądań)

```

---

## 4. Wyzwania Operacyjne i Alternatywy

| Cecha | Shamir's Secret Sharing (Manual Unseal) | Automatyczny Bootstrap (K8s Secret / RAM) |
| --- | --- | --- |
| **Downtime po restarcie** | Wymaga ręcznej interwencji / wpisania $K$ kluczy. | Przebiega automatycznie w kilka sekund. |
| **Przechowywanie klucza** | Brak klucza na dysku i w konfiguracji klastra. | Klucz montowany w `tmpfs` (pamięć RAM) z klastra. |
| **Rekomendowane zastosowanie** | Bankowość, systemy multi-tenant z podziałem odpowiedzialności. | Standardowe mikroserwisy w środowiskach K3s/K8s. |