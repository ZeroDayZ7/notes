### 1. Protokoły, Standardy i Aplikacje w Robotyce AMR

| Kategoria | Nazwa | Rozwiniecie skrótu | Zastosowanie / Opis |
| --- | --- | --- | --- |
| **Flota & IoT** | **VDA 5050** | Verband der Automobilindustrie 5050 | Przemysłowy standard komunikacji AMR/AGV z Fleet Managerem (MQTT/JSON). |
| **Flota & IoT** | **MQTT** | Message Queuing Telemetry Transport | Lekki protokół pub/sub do telemetrii i wysyłania zadań (VDA 5050). |
| **Przemysł** | **OPC UA** | Open Platform Communications Unified Architecture | Standard komunikacji z PLC, stacjami załadunkowymi, bramami i WMS/MES. |
| **Przemysł** | **Modbus TCP** | Modbus Transmission Control Protocol | Prosty protokół do odczytu/zapisu rejestrów w PLC i czujnikach. |
| **Komunikacja** | **DDS** | Data Distribution Service | Protokół middleware pod spodem ROS 2 do wymiany danych w czasie rzeczywistym. |
| **Komunikacja** | **REST API** | Representational State Transfer API | Interfejs HTTP do integracji floty z zewnętrznymi systemami ERP/WMS. |
| **Komunikacja** | **WebSockets** | WebSockets Protocol | Dwukierunkowy kanał realtime do paneli operatora (HMI/Dashboard). |
| **Framework** | **ROS 2** | Robot Operating System 2 | Główny framework middleware do budowy oprogramowania robota. |
| **Nawigacja** | **Nav2** | Navigation 2 | Stack ROS 2 do planowania tras, sterowania i omijania przeszkód. |
| **Lokalizacja** | **SLAM** | Simultaneous Localization and Mapping | Jednoczesne budowanie mapy otoczenia i lokalizacja robota. |
| **Lokalizacja** | **AMCL** | Adaptive Monte Carlo Localization | Algorytm probabilistyczny do lokalizacji robota na znanej mapie 2D. |
| **Diagnostyka** | **RViz2** | ROS Visualization 2 | Narzędzie graficzne do wizualizacji map, trajektorii i chmur punktów. |
| **Diagnostyka** | **Foxglove** | Foxglove Studio | Nowoczesny, webowy dashboard do telemetrii, wykresów i wizualizacji AMR. |
| **Symulacja** | **Gazebo** | Gazebo Simulator (Harmonic) | Domyślny silnik symulacji fizyki i czujników 3D w środowisku ROS. |
| **Symulacja** | **Isaac Sim** | NVIDIA Isaac Simulator | Fotorealistyczny symulator 3D oparty na Omniverse z akceleracją GPU. |
| **Symulacja** | **Webots** | Webots Open Source Robot Simulator | Lekki i łatwy w konfiguracji symulator robotów. |
| **System** | **Linux / WSL2** | Ubuntu 24.04 LTS / Windows Subsystem for Linux | Podstawowy OS uruchomieniowy i środowisko deweloperskie. |
| **System** | **Docker** | Docker Containers | Konteneryzacja węzłów ROS 2, orkiestracja i izolacja środowisk. |

---

### 2. C++20 w Robotyce AMR – Co musisz znać?

| Mechanizm C++20 | Zastosowanie w AMR |
| --- | --- |
| **Concepts & Constraints** | Weryfikacja typów danych w szablonach (np. ograniczanie typów dla macierzy transformacji). |
| **Ranges (`std::ranges`)** | Wydajne i czytelne filtrowanie chmur punktów z LiDAR-a oraz danych z sensorów. |
| **Coroutines (`co_await`, `co_yield`)** | Asynchroniczna obsługa I/O (I/O REST API, obsługa zdarzeń w komunikacji VDA 5050/MQTT). |
| **`std::span`** | Bezpieczny, bezkopioWy wgląd w bufory pamięci (dane z kamer, LiDAR-ów, surowe pakiety UDP/DDS). |
| **`std::jthread` & `std::stop_token**` | Bezpieczne zarządzanie wątkami w czasie rzeczywistym z automatycznym dołączaniem i przerywaniem. |
| **`std::format`** | Szybkie i bezpieczne formatowanie logów diagnostycznych i komunikatów. |
| **Smart Pointers (`std::shared_ptr`, `unique_ptr`)** | Zarządzanie pamięcią bez wycieków przy przesyłaniu komunikatów ROS 2 (`rclcpp`). |
| **Chrono & Date** | Precyzyjne znacznikowanie czasu danych z czujników (Timestamping) na potrzeby fuzji danych. |

---

### 3. "Przepis na Ciasto" – Przepis na Stworzenie Autonomicznego Robota (A-Z)

1. **Model Robota (URDF/SDF):** Stworzenie cyfrowego opisu fizycznego robota (wymiary, masy, stawy, koła, pozycje czujników).
2. **Środowisko Symulacyjne:** Odpalenie modelu w Gazebo/Isaac Sim i podpięcie wirtualnego sterowania kołami (DiffDrive / Ackermann).
3. **Sterowniki Czujników (Driver Layer):** Podpięcie i publikacja w ROS 2 danych z LiDAR-a (`LaserScan`), IMU oraz odometrii kół.
4. **Fuzja Danych i Odometria:** Skonfigurowanie węzła `robot_localization` (EKF) do wyliczenia pozycji robota w przestrzeni (`odom`).
5. **Tworzenie Mapy (SLAM):** Przejechanie robotem w symulacji/realu i wygenerowanie mapy 2D z użyciem `slam_toolbox`.
6. **Konfiguracja Stacku Nav2:** Ustawienie warstw mapy kosztów (*Costmaps*), planera globalnego (A*/Dijkstra) i lokalnego (MPPI/TEB).
7. **Obsługa Stref Bezpieczeństwa (Safety):** Integracja logiki zwalniania/zatrzymania przy braku reakcji (integracja z Safety PLC / STO).
8. **Mostek Komunikacji (VDA 5050 Bridge):** Napisanie/skonfigurowanie węzła w C++ przeliczającego rozkazy z MQTT (VDA 5050) na cele w Nav2.
9. **Integracja z Flotą i WMS:** Przetestowanie wysyłania zadań z serwera floty, obsługi stacji ładowania oraz zgłaszania błędów.
10. **Konteneryzacja i CI/CD:** Spakowanie kodu w kontenery Dockerowe i ustawienie automatycznych testów integracyjnych w pipeline.