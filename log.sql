-- Keep a log of any SQL queries you execute as you solve the mystery.
-- the theft took place on July 28, 2021 and that it took place on Humphrey Street.

-- Read the crime report for July 28, 2021 on Humphrey Street
-- Result: Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery.
-- Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.

SELECT description
FROM crime_scene_reports
WHERE year = '2021' AND month = '7' AND day = '28' AND street = 'Humphrey Street';

-- Read 3 interviews:
-- July 28, 2021
-- all mention 'bakery'
SELECT name, transcript
FROM interviews
WHERE year = '2021' AND month = '7' AND day = '28'
AND transcript LIKE '%bakery%';

-- RUTH:
-- Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away.
-- If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.

-- EUGENE:
-- I don't know the thief's name, but it was someone I recognized.
-- Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.

-- RAYMOND:
-- As the thief was leaving the bakery, they called someone who talked to them for less than a minute.
-- In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow.
-- The thief then asked the person on the other end of the phone to purchase the flight ticket.



-- LEADS:
-- 1. between 10:15am - 10:25am thief left bakery parking lot. check security footage
    -- returns license plate

-- 2. before 10:15am thief withdrew money from ATM on Leggett St
    -- returns amount and account number

-- 3. flight on July 29, 2021 first leaving Fiftyville
    -- they're going to LGA (destination airport code 4)
    -- 8:20am flight # 36

-- 4. Phone call: thief called someone just after 10:15am for less than one minute, asked them to buy ticket



/*///////////////////
-- LEAD #1:
////////////////// */
    -- between 10:15am - 10:25am thief left bakery parking lot. check security footage (returns license place )
SELECT license_plate
FROM bakery_security_logs
WHERE year = '2021' AND month = '7' AND day = '28'
AND hour = '10' AND minute BETWEEN 15 AND 25
AND activity = 'exit';

-- +---------------+
-- | license_plate |
-- +---------------+
-- | 5P2BI95       |
-- | 94KL13X       |
-- | 6P58WS2       |
-- | 4328GD8       |
-- | G412CB7       |
-- | L93JTIZ       |
-- | 322W7JE       |
-- | 0NTHK55       |
-- +---------------+

-- Query to find overlap between license plates and lead #2:
WITH license_plates AS (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND hour = '10' AND minute BETWEEN 15 AND 25
    AND activity = 'exit'
),
atm_accounts AS (
    SELECT account_number
    FROM atm_transactions
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw'
)
SELECT DISTINCT people.name, people.id, people.license_plate, bank_accounts.account_number
FROM people, atm_transactions, bank_accounts, atm_accounts, license_plates
WHERE atm_accounts.account_number = bank_accounts.account_number
AND bank_accounts.person_id = people.id
AND license_plates.license_plate = people.license_plate;

-- +-------+--------+---------------+----------------+
-- | name  |   id   | license_plate | account_number |
-- +-------+--------+---------------+----------------+
-- | Iman  | 396669 | L93JTIZ       | 25506511       |
-- | Diana | 514354 | 322W7JE       | 26013199       |
-- | Luca  | 467400 | 4328GD8       | 28500762       |
-- | Bruce | 686048 | 94KL13X       | 49610011       |
-- +-------+--------+---------------+----------------+



/*///////////////////
-- LEAD #2:
////////////////// */
    -- before 10:15am thief withdrew money from ATM on Leggett St
SELECT *
FROM atm_transactions
WHERE year = '2021' AND month = '7' AND day = '28'
AND atm_location = 'Leggett Street'
AND transaction_type = 'withdraw';

-- +-----+----------------+------+-------+-----+----------------+------------------+--------+
-- | id  | account_number | year | month | day |  atm_location  | transaction_type | amount |
-- +-----+----------------+------+-------+-----+----------------+------------------+--------+
-- | 246 | 28500762       | 2021 | 7     | 28  | Leggett Street | withdraw         | 48     |
-- | 264 | 28296815       | 2021 | 7     | 28  | Leggett Street | withdraw         | 20     |
-- | 266 | 76054385       | 2021 | 7     | 28  | Leggett Street | withdraw         | 60     |
-- | 267 | 49610011       | 2021 | 7     | 28  | Leggett Street | withdraw         | 50     |
-- | 269 | 16153065       | 2021 | 7     | 28  | Leggett Street | withdraw         | 80     |
-- | 288 | 25506511       | 2021 | 7     | 28  | Leggett Street | withdraw         | 20     |
-- | 313 | 81061156       | 2021 | 7     | 28  | Leggett Street | withdraw         | 30     |
-- | 336 | 26013199       | 2021 | 7     | 28  | Leggett Street | withdraw         | 35     |
-- +-----+----------------+------+-------+-----+----------------+------------------+--------+

-- GET NAMES OF PEOPLE WITH THE BANK ACCOUNTS:
WITH atm_accounts AS (
    SELECT account_number
    FROM atm_transactions
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw'
)
SELECT DISTINCT people.name, people.id, people.license_plate, bank_accounts.account_number
FROM people, atm_transactions, bank_accounts, atm_accounts
WHERE atm_accounts.account_number = bank_accounts.account_number
AND bank_accounts.person_id = people.id;

-- +---------+--------+---------------+----------------+
-- |  name   |   id   | license_plate | account_number |
-- +---------+--------+---------------+----------------+
-- | Brooke  | 458378 | QX4YZN3       | 16153065       |
-- | Iman    | 396669 | L93JTIZ       | 25506511       |
-- | Diana   | 514354 | 322W7JE       | 26013199       |
-- | Kenny   | 395717 | 30G67EN       | 28296815       |
-- | Luca    | 467400 | 4328GD8       | 28500762       |
-- | Bruce   | 686048 | 94KL13X       | 49610011       |
-- | Taylor  | 449774 | 1106N58       | 76054385       |
-- | Benista | 438727 | 8X428L0       | 81061156       |
-- +---------+--------+---------------+----------------+



/*///////////////////
-- LEAD #3:
////////////////// */
    -- first flight on July 29, 2021 leaving Fiftyville
SELECT destination_airport_id, year, month, day, hour, minute, flights.id, abbreviation, full_name
FROM flights, airports
WHERE airports.id = flights.origin_airport_id
AND airports.city = 'Fiftyville'
AND year = '2021' AND month = '7' AND day = '29'
ORDER BY hour
LIMIT 1;

-- +------------------------+------+-------+-----+------+--------+----+--------------+-----------------------------+
-- | destination_airport_id | year | month | day | hour | minute | id | abbreviation |          full_name          |
-- +------------------------+------+-------+-----+------+--------+----+--------------+-----------------------------+
-- | 4                      | 2021 | 7     | 29  | 8    | 20     | 36 | CSF          | Fiftyville Regional Airport |

-- Track down destination airport id:
SELECT *
FROM airports
WHERE id = 4;

-- +----+--------------+-------------------+---------------+
-- | id | abbreviation |     full_name     |     city      |
-- +----+--------------+-------------------+---------------+
-- | 4  | LGA          | LaGuardia Airport | New York City |
-- +----+--------------+-------------------+---------------+

-- Query for passengers on that flight:
WITH the_flight AS (
    SELECT flights.id
    FROM flights, airports
    WHERE airports.id = flights.origin_airport_id
    AND airports.city = 'Fiftyville'
    AND year = '2021' AND month = '7' AND day = '29'
    ORDER BY hour
    LIMIT 1
)
SELECT passengers.passport_number
FROM passengers, the_flight
WHERE the_flight.id = passengers.flight_id;

-- +-----------------+
-- | passport_number |
-- +-----------------+
-- | 7214083635      |
-- | 1695452385      |
-- | 5773159633      |
-- | 1540955065      |
-- | 8294398571      |
-- | 1988161715      |
-- | 9878712108      |
-- | 8496433585      |
-- +-----------------+



/*///////////////////
-- LEAD #4:
////////////////// */
    -- Phone call: thief called someone just after 10:15am for less than one minute, asked them to buy ticket

-- Query to find phone call:
    SELECT *
    FROM phone_calls
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND duration <= 60;

-- +-----+----------------+----------------+------+-------+-----+----------+
-- | id  |     caller     |    receiver    | year | month | day | duration |
-- +-----+----------------+----------------+------+-------+-----+----------+
-- | 221 | (130) 555-0289 | (996) 555-8899 | 2021 | 7     | 28  | 51       |
-- | 224 | (499) 555-9472 | (892) 555-8872 | 2021 | 7     | 28  | 36       |
-- | 233 | (367) 555-5533 | (375) 555-8161 | 2021 | 7     | 28  | 45       |
-- | 234 | (609) 555-5876 | (389) 555-5198 | 2021 | 7     | 28  | 60       |
-- | 251 | (499) 555-9472 | (717) 555-1342 | 2021 | 7     | 28  | 50       |
-- | 254 | (286) 555-6063 | (676) 555-6554 | 2021 | 7     | 28  | 43       |
-- | 255 | (770) 555-1861 | (725) 555-3243 | 2021 | 7     | 28  | 49       |
-- | 261 | (031) 555-6622 | (910) 555-3251 | 2021 | 7     | 28  | 38       |
-- | 279 | (826) 555-1652 | (066) 555-9701 | 2021 | 7     | 28  | 55       |
-- | 281 | (338) 555-6650 | (704) 555-2131 | 2021 | 7     | 28  | 54       |
-- +-----+----------------+----------------+------+-------+-----+----------+


-- Query to combine lead #1 & #2 with phone_numbers:

WITH license_plates AS (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND hour = '10' AND minute BETWEEN 15 AND 25
    AND activity = 'exit'
),
atm_accounts AS (
    SELECT account_number
    FROM atm_transactions
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw'
),
phone AS (
    SELECT *
    FROM phone_calls
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND duration <= 60
)
SELECT DISTINCT people.name, people.id, people.license_plate, people.passport_number, bank_accounts.account_number
FROM people, atm_transactions, bank_accounts, atm_accounts, license_plates, phone
WHERE atm_accounts.account_number = bank_accounts.account_number
AND bank_accounts.person_id = people.id
AND license_plates.license_plate = people.license_plate
AND people.phone_number = phone.caller;

-- +-------+--------+---------------+----------------+
-- | name  |   id   | license_plate | account_number |
-- +-------+--------+---------------+----------------+
-- | Diana | 514354 | 322W7JE       | 26013199       |
-- | Bruce | 686048 | 94KL13X       | 49610011       |
-- +-------+--------+---------------+----------------+

-- WHAT THIS MEANS:
    -- Diana & Bruce have:
        -- license plates that left the bakery parking lot
        -- withdrew money that morning from the Leggett St atm
        -- made phone calls on that day for less than one minute
            -- the person they called bought the flight ticket
        -- SEE IF THEY ARE PASSENGERS ON THE NEXT FLIGHT??

-- MEGA QUERY TO COMBINE ABOVE WITH PASSPORT NUMBER:
WITH license_plates AS (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND hour = '10' AND minute BETWEEN 15 AND 25
    AND activity = 'exit'
),
atm_accounts AS (
    SELECT account_number
    FROM atm_transactions
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw'
),
phone AS (
    SELECT *
    FROM phone_calls
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND duration <= 60
),
the_flight AS (
    SELECT flights.id, flights.destination_airport_id
    FROM flights, airports
    WHERE airports.id = flights.origin_airport_id
    AND airports.city = 'Fiftyville'
    AND year = '2021' AND month = '7' AND day = '29'
    ORDER BY hour
    LIMIT 1
)
SELECT DISTINCT people.name, people.passport_number, airports.city, people.phone_number
FROM people, atm_transactions, bank_accounts, atm_accounts, license_plates, phone, the_flight, passengers, airports
WHERE atm_accounts.account_number = bank_accounts.account_number
AND bank_accounts.person_id = people.id
AND license_plates.license_plate = people.license_plate
AND people.phone_number = phone.caller
AND the_flight.id = passengers.flight_id
AND passengers.passport_number = people.passport_number
AND the_flight.destination_airport_id = airports.id;

-- +-------+-----------------+---------------+----------------+
-- | name  | passport_number |     city      |  phone_number  |
-- +-------+-----------------+---------------+----------------+
-- | Bruce | 5773159633      | New York City | (367) 555-5533 |
-- +-------+-----------------+---------------+----------------+

--------------------------------
--------------------------------

-- To find the accomplice:

-- SELECT name
-- FROM people
-- WHERE phone_number = '(375) 555-8161' -- Robin
-- OR phone_number = '(367) 555-5533';  -- Bruce

-- WITH phone AS (
--     SELECT *
--     FROM phone_calls
--     WHERE year = '2021' AND month = '7' AND day = '28'
--     AND duration <= 60
-- )


-- FINAL QUERY WITH THIEF & ACCOMPLICE:

WITH license_plates AS (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND hour = '10' AND minute BETWEEN 15 AND 25
    AND activity = 'exit'
),
atm_accounts AS (
    SELECT account_number
    FROM atm_transactions
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw'
),
phone AS (
    SELECT *
    FROM phone_calls
    WHERE year = '2021' AND month = '7' AND day = '28'
    AND duration <= 60
),
the_flight AS (
    SELECT flights.id, flights.destination_airport_id
    FROM flights, airports
    WHERE airports.id = flights.origin_airport_id
    AND airports.city = 'Fiftyville'
    AND year = '2021' AND month = '7' AND day = '29'
    ORDER BY hour
    LIMIT 1
),
thief AS (
    SELECT DISTINCT people.name, people.passport_number, airports.city as 'Escaped To', people.phone_number
    FROM people, atm_transactions, bank_accounts, atm_accounts, license_plates, phone, the_flight, passengers, airports
    WHERE atm_accounts.account_number = bank_accounts.account_number
    AND bank_accounts.person_id = people.id
    AND license_plates.license_plate = people.license_plate
    AND people.phone_number = phone.caller
    AND the_flight.id = passengers.flight_id
    AND passengers.passport_number = people.passport_number
    AND the_flight.destination_airport_id = airports.id
),
accomplice AS (
    SELECT people.name
    FROM people, phone, thief
    WHERE phone.caller = thief.phone_number
    AND phone.receiver = people.phone_number
)
SELECT thief.name, thief.'Escaped To', accomplice.name as 'Accomplice'
FROM thief, accomplice;