import serial
import time

# --- Configuration ---
SERIAL_PORT = 'COM18' 
BAUD_RATE = 9600
OUTPUT_FILENAME = 'puf_responses_16bit_full.csv'

# We will test all 2^16 = 65,536 challenges
NUM_SEQUENTIAL_CHALLENGES_TO_TEST = 2**16

def get_puf_response_16bit(serial_connection, challenge_16bit):
    """Sends a 16-bit challenge as two 8-bit bytes and returns the response."""
    try:
        # Break the 16-bit integer into two 8-bit bytes (little-endian)
        challenge_bytes = [
            (challenge_16bit >> 0) & 0xFF,
            (challenge_16bit >> 8) & 0xFF
        ]
        serial_connection.write(bytes(challenge_bytes))
        response = serial_connection.read(1)
        
        if response:
            return response.decode('ascii')
        else:
            return "Timeout"
    except serial.SerialException:
        return "Error"

def main():
    """
    Main function to test the 16-bit PUF with all sequential challenges.
    """
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2)
        print(f"Successfully opened serial port {SERIAL_PORT}")
        time.sleep(2)
    except serial.SerialException as e:
        print(f"Fatal: Could not open serial port '{SERIAL_PORT}'. Error: {e}")
        return

    print(f"\nStarting FULL 16-BIT PUF characterization...")
    print(f"Testing all {NUM_SEQUENTIAL_CHALLENGES_TO_TEST} challenges from 0 to {NUM_SEQUENTIAL_CHALLENGES_TO_TEST - 1}.")
    print(f"Results will be saved to '{OUTPUT_FILENAME}'")

    # Generate a sequence of all 65,536 challenges.
    all_challenges = range(NUM_SEQUENTIAL_CHALLENGES_TO_TEST)

    try:
        with open(OUTPUT_FILENAME, 'w', newline='') as f:
            f.write("Serial_Number,Challenge_Decimal,Challenge_Hex,Response_Bit\n")

            for challenge in all_challenges:
                response = get_puf_response_16bit(ser, challenge)
                
                serial_number = challenge + 1
                challenge_hex = f"0x{challenge:04X}"
                
                f.write(f"{serial_number},{challenge},{challenge_hex},{response}\n")
                
                if (serial_number) % 1024 == 0 or serial_number == NUM_SEQUENTIAL_CHALLENGES_TO_TEST:
                    print(f"  Progress: {serial_number} / {NUM_SEQUENTIAL_CHALLENGES_TO_TEST} challenges completed...")

    except IOError as e:
        print(f"Fatal: Could not write to file '{OUTPUT_FILENAME}'. Error: {e}")
    except KeyboardInterrupt:
        print("\nProcess interrupted by user (Ctrl+C). Closing port.")
    finally:
        ser.close()
        print("\nCharacterization complete. Serial port closed.")

if __name__ == "__main__":
    main()
