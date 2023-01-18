# Test Descriptions

## Block 2
TODO 

## Block 3
Two docker containers are started for all groups combined (for efficiency reasons).
`hash-client` runs the client code, while `hash-server` runs the server code.
Both containers are connected via a docker network named `testnet`.
They have no access to the Internet. 

NOTE: Clients and Servers are tested completely separately, 
i.e. a client of group does not communicate with the server of the same group.
They are always tested against code running in the testbench. 

### Client
Before each testcase, `hash-server` is restarted to free up the ports.
`hash-client` is not restarted (time-saving) but running clients are killed before the start.

#### correct_flags_get
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 GET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received) --> _Never Gonna Give You Up!_
6. Assert that first Byte of Request is correct

#### correct_flags_set
1. A server thread is started on port 1400
2. Students client is executed with `printf "Never gonna give you up!" | ./client hash-server 1400 SET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received)
6. Assert that first Byte of Request is correct

#### correct_flags_del
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 DEL "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received)
6. Assert that first Byte of Request is correct

#### correct_value_len_set
1. A server thread is started on port 1400
2. Students client is executed with `printf "Never gonna give you up!" | ./client hash-server 1400 SET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received)
6. Assert that Value Length == 24 (Flags and Key Length are ignored) 

#### correct_value_len_long_set
1. A server thread is started on port 1400
2. Students client is executed with `printf {value} | ./client hash-server 1400 SET "Daft Punk"` via (`bash -c`)
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received)
6. Assert that Value Length == 24480 (Flags and Key Length are ignored) 

Value is "_Around the world!_" repeated 1440 times --> 24480 bytes 
#### correct_key_len_get
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 GET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received) --> "_Never Gonna Give You Up!_"
6. Assert that Key Length == 11 (Flags and Value Length are ignored) 

#### correct_key_len_long_get
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 GET {Long Key}` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive 7 Bytes for the header
5. Server sends reply packet with ACK set (independently from the garbage we may have received) --> "_No more_" 
6. Assert that Key Length == 11 (Flags and Value Length are ignored) 

Key is "_What is love? Baby dont hurt me! Dont hurt me!_" repeated 100 times.
#### simple_get_correct_output
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 GET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive the complete packet (lengths in header must be correct for this to work)
5. Server sends reply packet with ACK set (independently from the garbage we may have received) --> _Never Gonna Give You Up!_
5. Wait up to 2 seconds until the complete reply could be sent 
6. Assert that Stdout of Client matches regex ``Never Gonna Give You Up!\n?\0?``

#### long_get_correct_output
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 GET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive the complete packet (lengths in header must be correct for this to work)
5. Server sends reply packet with ACK set (independently from the garbage we may have received)
5. Wait up to 2 seconds until the complete reply could be sent 
6. Assert that Stdout of Client matches regex ``{value}\n?\0?``

The sent value  "_Never Gonna Give You Up!_" repeated 1000 times --> 24000 bytes

#### simple_get_correct_packet
1. A server thread is started on port 1400
2. Students client is executed with `./client hash-server 1400 GET "Rick Astley"` via (`bash -c`) 
3. Wait up to 2 seconds until client connects to server
4. Wait up to 2 seconds until we receive the complete packet (lengths in header must be correct for this to work)
5. Server sends reply packet with ACK set (independently from the garbage we may have received) --> _Never Gonna Give You Up!_
5. Wait up to 2 seconds until the complete reply could be sent 
6. Assert that parsing of the request packet is not throwing an Exception (aka. valid packet). 
See [General Errors](#general-errors).
7. Assert that the parsed value of the request packet is empty

### Server

Before each testcase, `hash-server` is restarted to free up the ports.

#### set_ack

1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sents `SET` packet. Key: `Eduard Chil` Value: `Trololololo!`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. TB asserts that key length is zero.
10. TB asserts that value length is zero.

#### set_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sents `SET` packet. Key: `Eduard Chil` Value: `Trololololo!`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sents `GET` packet for key `Eduard Chil`. 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. TB asserts that key equals `Eduard Chil`
15. TB asserts that value equals `Trololololo!`

#### get_empty

1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sents `GET` packet. Key: `Eduard Chil`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. ~~TB asserts that the key length is zero.~~
9. TB asserts that the value length is zero.

**NOTE:** We do not care whether or not the ACK bit is set.

#### del_empty

1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sents `DELETE` packet. Key: `Eduard Chil`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that the key length is zero.
9. TB asserts that the value length is zero.

**NOTE:** We do not care whether or not the ACK bit is set.

#### set_nullkey_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sends `SET` packet. Key: `1337HaXX\0r` Value: `Robert'DROP TAB TABLE Students;--`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sends `GET` packet for key `1337HaXX\0r`. 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. TB asserts that key equals `1337HaXX\0r`
15. TB asserts that value equals `Robert'DROP TAB TABLE Students;--`

#### set_null_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sends `SET` packet. Key: `Eduard Chil` Value: `Tr\0l\0l\0l\0l\0!`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sends `GET` packet for key `Eduard Chil`. 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. TB asserts that key equals `Eduard Chil`
15. TB asserts that value equals `Tr\0l\0l\0l\0l\0!`

#### set_long_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sends `SET` packet. Key: `Fresh Prince of Bel Air` 
Value: The complete lyrics of Fresh Prince of Bel Air repeated 100 times -> `Now, this is a story all about how [...]` 173700 Bytes.
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sends `GET` packet for key `Fresh Prince of Bel Air`. 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. TB asserts that key equals `Fresh Prince of Bel Air`
15. TB asserts that value matches. 

#### set_get_del_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sends `SET` packet. Key: `Eduard Chil` Value: `Trololololo!`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sends `GET` packet for key `Eduard Chil`. 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. TB asserts that key equals `Eduard Chil`
15. TB asserts that value equals `Trololololo!`
16. New Client thread is started. Steps 2-4 are repeated.
17. Client sends `DELETE` packet for key `Eduard Chil`. 
18. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
19. TB tries to parse response packet. See [General Errors](#general-errors).
20. TB asserts that ACK bit is set.
21. New Client thread is started. Steps 2-4 are repeated.
22. Client sends `GET` packet for key `Eduard Chil`. 
23. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
24. TB tries to parse response packet. See [General Errors](#general-errors).
25. TB asserts that the value is empty.

**NOTE**: TB does not care about the ACK bit and does not care about the key in the final response packet. 
#### set_set_del_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sends `SET` packet. Key: `Eduard Chil` Value: `Trololololo!`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sends `SET` packet for key `Eduard Chil`. New Value: `Hohohohoohooooohooo!` 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. New Client thread is started. Steps 2-4 are repeated.
15. Client sends `DELETE` packet for key `Eduard Chil`. 
16. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
17. TB tries to parse response packet. See [General Errors](#general-errors).
18. TB asserts that ACK bit is set.
19. New Client thread is started. Steps 2-4 are repeated.
20. Client sends `GET` packet for key `Eduard Chil`. 
21. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
22. TB tries to parse response packet. See [General Errors](#general-errors).
23. TB asserts that the value is empty.

**NOTE**: TB does not care about the ACK bit and does not care about the key in the final response packet. 

#### set_get_set_get
1. Students server is started: ``./server 1400``
2. Client thread is started in network namespace of `hash-client`.
3. TB waits up to 2 seconds to resolve the IP `hash-server`.
If this fails, you probably need to restart the testbench.
4. TB waits up to 2 seconds to establish the connection to the server. 
5. Client sends `SET` packet. Key: `Eduard Chil` Value: `Trololololo!`
6. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
7. TB tries to parse response packet. See [General Errors](#general-errors).
8. TB asserts that ACK bit is set.
9. New Client thread is started. Steps 2-4 are repeated.
10. Client sends `GET` packet for key `Eduard Chil`. 
11. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
12. TB tries to parse response packet. See [General Errors](#general-errors).
13. TB asserts that ACK bit is set.
14. TB asserts that key equals `Eduard Chil`
15. TB asserts that value equals `Trololololo!`
16. New Client thread is started. Steps 2-4 are repeated.
17. Client sends `SET` packet for key `Eduard Chil`. New value: `Hohohohooohoo!Hohohohooohoo!` 
18. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
19. TB tries to parse response packet. See [General Errors](#general-errors).
20. TB asserts that ACK bit is set.
21. New Client thread is started. Steps 2-4 are repeated.
22. Client sends `GET` packet for key `Eduard Chil`. 
23. Client thread receives until server closes the connection.
TB waits up to 3 seconds for this to happen.
24. TB tries to parse response packet. See [General Errors](#general-errors).

A very common error is that the students server returns `Hohohohoooho`, i.e. a truncated new value.
This is an indicator that the students set the value length incorrectly for already existing hash table entries. 

**NOTE**: Due to a copy&paste error step 20. might produce a confusing error msg `Server did not acknowledge DEL operation!`.
This, of course, refers to the SET operation not being acknowledged. This should be fixed by now.  

### General Errors 

#### ValueError('Header too short!')
Testbench tried to determine the packet length from the header, but the function received less than 7 Bytes.
Usually occurs when the client or server closes the connection but we still expect a packet.

#### ValueError('Received Packet too short!')
Basically the same case as the previous error with the difference that we try to parse a packet that is less than (7 + Key Length + Value Length) bytes long.
Either the connection was closed to early or the header contains wrong key/value lengths.
This error also implies that we got the header.  

#### ValueError('Conflicting Flag bits set!')
TB tried to parse a packet but more than one bit of method fields was set, i.e. GET and SET or DEL and SET.
Usually a hint that the header marshalling is completely messed up.

#### ValueError('No method set in Flag bits!')
TB tried to parse a packet but could not determine whether its GET/SET/DEL because no flag bit was set.
This error is raised independently from the ACK bit.

## Block 4
Two docker containers are started for all groups combined (for efficiency reasons).
`hash-peer` runs the students code, while `mock-peer` is used as shell to run some testbench code in it.
Both containers are connected via a docker network named `testnet`.
They have no access to the Internet. 

### Regular Testcases
For this group of testcases only one instance of the student peer is started on the `hash-peer` container.
A fake-server is started on mock-peer which will accept connections on port `1401`.
The behaviour of the fake-server depends on the testcase. 

#### trigger_lookup_minimal
1. Peer is started on port `1400` with ID `10`.
   Predecessor is set to `1`.
   Successor is set to `21616`.
2. A client sends a `GET` packet for key `Trigger_dat_lookup`.
   This should map to ID `21818` thus requires a lookup. 
3. TB expects a control-type packet (control bit must be set) to be sent within two seconds to the fake successor.

**NOTE**: We do not evaluate the contents of the packet. 
          Any valid control packet is enough to pass the testcase.

#### trigger_get_minimal
1. Peer is started on port `1400` with ID `10`.
   Predecessor is set to `1`.
   Successor is set to `18282`.
2. A client sends a `GET` packet for key `Gimme_a_GET`.
   This should map to ID `18281` thus it does _NOT_ require a lookup. 
3. TB expects a valid data-type packet (control bit must be zero) to be sent within two seconds to the fake successor.

**NOTE**: We do not evaluate the contents of the packet. 
          Any valid data packet is enough to pass the testcase.

#### forward_lookup
1. Peer is started on port `1400` with ID `10`.
   Predecessor is set to `1`.
   Successor is set to `1025`.
2. A `LOOKUP` packet is sent to the peer for ID `2000`.
   Node-ID of the packet is set to `10000`.
   The port and IP fields are filled with port 4096 and the current IP of the `mock-container`.

3. TB expects a valid control-type packet at the fake successor within 2 seconds.

**NOTE**: We do not evaluate the contents of the packet. 
          Any valid control packet is enough to pass the testcase.

#### get_full_circle
1. Peer is started on port `1400` with ID `10`.
   Predecessor is set to `1`.
   Successor is set to `21607`.
2. An additional fake-peer is started on `mock-container` on port `1500`.
3. A client sends a `GET` request for the key `The ciiirrcle of Chord!`.
   This key should map to ID `21608` and therefore trigger a lookup.
4. The TB expects a `LOOKUP` packet to be sent to the fake successor within two seconds.
   The hash id of the packet must equal `21608`.
   The node id of the packet must be `10`.
   The IP field must match the IP of the `hash-peer` container in Big Endian format.
   The port field must be equal to `1400`. 

5. The fake successor will respond to the lookup with a `REPLY` message containing the information of the
   fake-peer.
   For this message a new connection is opened by the successor, so it appears like a random node from the ring.

6. The TB expects a valid data packet to be sent to the fake-peer within two seconds.
   The key field of said packet must match the initial key.

7. The fake-peer will reply to the `GET` request with the value `What goes around comes around!`

8. Lastly, the TB expects a response to be sent to the client within two seconds.
   The key of the response must match our initial key.
   The value field must match the value sent by the fake-peer. 

### Student Code Testcases
For these testcases we start multiple instances of the students peer code in a ring.
Therefore, the testcases can be passed while not being 100% compliant with the given task,
as long as the code is consistent.
A typical example would be marshalling IPv4 addresses accidentally in little-endian format.
Such an error will only surface when dealing with external peers.

The peers all run on the `hash-peer` container (using ascending port numbers from port `1400`) and are supplied with their publicly visible IP.
**NOTE**: After starting each instance we wait 50 ms before we start the next one to avoid possible deadlocks.

#### student_ring_set_get_basic 
1. A ring is started with the following IDs: `[1000, 14107, 27214, 40321, 53428]` 
2. A client sends a `SET` request to peer `1000` with key `How do I exit vim?` (maps to `18543`) and value `https://stackoverflow.com/questions/11828270/how-do-i-exit-the-vim-editor`.
3. The TB expects a data packet in response to the client within two seconds. Note: We do not check the response.  
4. Another client sends a `GET` request for the same key to peer 40321.
5. The TB expects a data packet in response to the second client within two seconds.
   The value field of the packet must match.

#### student_ring_set_del_set_get
1. A ring is started with the following IDs: `[1000, 14107, 27214, 40321, 53428]` 
2. A client sends a `SET` request to peer `1000` with key `My C-Programming-Skillz` (maps to `19833`) and value `100% !!11einself!`.
3. The TB expects a data packet in response to the client within two seconds. Note: We do not check the response.  
4. Another client sends a `DELETE` request for the same key to peer `53428`.
5. The TB expects a data packet in response to the client within three seconds. 
   Note: We do not check the response.  
6. A third client sends a `SET` request for the same key to peer `14107` and changes the value to `sendto()sendto()sendto()sendto()`.
7. The TB expects a data packet in response to the client within two seconds. 
   Note: We do not check the response.  
6. A fourth client sends a `GET` request for the same key to peer `1000`. 
   The TB expects a data packet in response to the client within three seconds. 
   The TB expects the value to match `sendto()sendto()sendto()sendto()`.

#### student_ring_long_value
1. A ring is started with the following IDs: `[1000, 14107, 27214, 40321, 53428]` 
2. Client sends `SET` packet to peer `1000`. Key: `Fresh Prince of Bel Air` 
   Value: The complete lyrics of Fresh Prince of Bel Air repeated 100 times 
   -> `Now, this is a story all about how [...]` 173700 Bytes.
3. The TB expects a data packet in response to the client within two seconds. 
   Note: We do not check the response.  
4. Another client sends a `GET` request for the same key to peer `40321`.
5. The TB expects a data packet in response to the client within three seconds. 
   TB asserts that the values match exactly.  

#### student_ring_set_get_null
1. A ring is started with the following IDs: `[1000, 14107, 27214, 40321, 53428]` 
2. A Client sends `SET` packet to peer `1000`. 
   Key: `You still cannot handle \0 Bytes?` 
   Value: `https://www.tu-berlin.de/?id=76320`
3. The TB expects a data packet in response to the client within two seconds. 
   The response is not checked.
4. Another client sends `GET` to  peer `40321` for the same key.
5. The TB expects a data packet in response to the client within three seconds.
   TB asserts that the values match.
 
#### student_ring_set_set_get
1. A ring is started with the following IDs: `[1000, 14107, 27214, 40321, 53428]` 
2. A Client sends `SET` packet to peer `1000`. 
   Key: `How do I exit vim?` 
   Value: `RTFM!`
3. The TB expects a data packet in response to the client within two seconds. 
   The response is not checked.
4. Another client sends a `SET` packet for the same key to peer `14107`.
   New value: `https://stackoverflow.com/questions/11828270/how-do-i-exit-the-vim-editor`
5. The TB waits two seconds for a response.  
6. A third client sends a `GET` packet for the same key to peer `40321`.  
7. The TB waits three seconds for response.
   The TB asserts that the value exactly matches the second value it sent. 

NOTE: We send the shorter value first to make sure that the students set the value length correctly.

#### student_ring_set_get_cross_zero
1. A ring is started with the following IDs: `[1000, 14107, 27214, 40321, 53428]` 
2. A client sends a `SET` request to peer `53428`.
   Key: `How do I exit vim?` (maps to `18543` --> Node 27214)
   Value: `https://stackoverflow.com/questions/11828270/how-do-i-exit-the-vim-editor`.
3. The TB expects a data packet in response to the client within two seconds. 
   The response is not checked.
4. Another client sends a `GET` for the same key to node `14107`.  
5. The TB expects a data packet in response to the client within three seconds. 
   The TB asserts that the values match.
   
## Block 5

TODO

