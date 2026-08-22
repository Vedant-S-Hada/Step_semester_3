import java.util.Scanner;

public class ArmstrongCheck {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter number: ");
        int number = sc.nextInt();

        int origNumber = number; // Store original value[cite: 1]
        int sum = 0;             // Initialize sum[cite: 1]

        // Sum the cube of each digit[cite: 1]
        while (number > 0) {
            int digit = number % 10;
            sum += (digit * digit * digit);
            number = number / 10;
        }

        // Check if sum equals original number[cite: 1]
        if (sum == origNumber) {
            System.out.println("Is the number an Armstrong number? Yes");
        } else {
            System.out.println("Is the number an Armstrong number? No");
        }

        sc.close();
    }
}