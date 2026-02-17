import serial
import time

# --- Configuration ---
SERIAL_PORT = 'COM18' 
BAUD_RATE = 9600
OUTPUT_FILENAME = 'puf_responses_full_0_to_2_power_32.csv'

# WARNING: THE FOLLOWING VALUE WILL CAUSE THE SCRIPT TO RUN FOR OVER ONE YEAR.
# It is strongly recommended to use a smaller number like 10000.
NUM_SEQUENTIAL_CHALLENGES_TO_TEST = 2**32

def get_puf_response_32bit(serial_connection, challenge_32bit):
    """Sends a 32-bit challenge and returns the response."""
    try:
        challenge_bytes = [
            (challenge_32bit >> 0) & 0xFF,
            (challenge_32bit >> 8) & 0xFF,
            (challenge_32bit >> 16) & 0xFF,
            (challenge_32bit >> 24) & 0xFF
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
    Main function to test the PUF with every sequential challenge from 0 to 2^32 - 1.
    """
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2)
        print(f"Successfully opened serial port {SERIAL_PORT}")
        time.sleep(2)
    except serial.SerialException as e:
        print(f"Fatal: Could not open serial port '{SERIAL_PORT}'. Error: {e}")
        return

    print("\n--- WARNING ---")
    print(f"You have chosen to test all {NUM_SEQUENTIAL_CHALLENGES_TO_TEST} challenges.")
    print("This process will take more than one year to complete.")
    print("To stop the process, press Ctrl+C.")
    print("-----------------\n")
    print(f"Testing challenges from 0 to {NUM_SEQUENTIAL_CHALLENGES_TO_TEST - 1}.")
    print(f"Results will be saved to '{OUTPUT_FILENAME}'")

    # Generate a sequence of all 4.3 billion challenges.
    all_challenges = range(NUM_SEQUENTIAL_CHALLENGES_TO_TEST)

    try:
        with open(OUTPUT_FILENAME, 'w', newline='') as f:
            f.write("Serial_Number,Challenge_Decimal,Challenge_Hex,Response_Bit\n")

            for challenge in all_challenges:
                response = get_puf_response_32bit(ser, challenge)
                
                serial_number = challenge + 1
                challenge_hex = f"0x{challenge:08X}"
                
                f.write(f"{serial_number},{challenge},{challenge_hex},{response}\n")
                
                # Print progress every 1 million challenges
                if (serial_number) % 1000000 == 0:
                    print(f"  Progress: {serial_number / 1e6:.1f} million challenges completed...")

    except IOError as e:
        print(f"Fatal: Could not write to file '{OUTPUT_FILENAME}'. Error: {e}")
    except KeyboardInterrupt:
        print("\nProcess interrupted by user (Ctrl+C). Closing port.")
    finally:
        ser.close()
        print("\nCharacterization stopped. Serial port closed.")

if __name__ == "__main__":
    main()
