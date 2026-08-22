import java.util.Scanner;

public class PalindromeCheck {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter number: ");
        int number = sc.nextInt();
        
        int origNumber = number; // Store original value[cite: 1]
        int reversedNumber = 0;  // Initialize reversed sum[cite: 1]

        // Access each digit and reconstruct the reversed number[cite: 1]
        while (number > 0) {
            int digit = number % 10;
            reversedNumber = (reversedNumber * 10) + digit;
            number = number / 10;
        }

        // Compare reversed number with original number[cite: 1]
        if (reversedNumber == origNumber) {
            System.out.println("Is the number a Palindrome? Yes");
        } else {
            System.out.println("Is the number a Palindrome? No");
        }

        sc.close();
    }
}