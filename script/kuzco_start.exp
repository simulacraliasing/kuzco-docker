#!/usr/bin/expect -f

set timeout 30

set email $env(KUZCO_EMAIL)
set password $env(KUZCO_PASSWORD)

set code $env(WORKER_CODE)

spawn kuzco login

expect "*Enter your email*"

send "$email\r"

expect "*Enter your password*"

send "$password\r"

expect eof

set retries 3
for {set i 1} {$i <= $retries} {incr i} {

    spawn kuzco worker register --code $code

    expect {
        eof {
            puts "Worker registration successful."
            break
        }
        timeout {
            puts "Worker registration timed out, retrying..."
        }
    }
}

if {$i > $retries} {
    puts "Failed to register worker after $retries attempts."
} else {
    puts "Starting kuzco worker..."
}
