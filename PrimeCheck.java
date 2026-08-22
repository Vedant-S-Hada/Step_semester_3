import java.util.Scanner;

public class PrimeCheck {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter a number: ");
        int number = sc.nextInt();

        boolean isPrime = true;

        if (number <= 1) {
            isPrime = false;
        } else {
            // Loop from i = 2 to i < number
            for (int i = 2; i < number; i++) {
                if (number % i == 0) {
                    isPrime = false; // Factor found
                    break;          // Break immediately
                }
            }
        }

        if (isPrime) {
            System.out.println("Is the number a Prime number? Yes");
        } else {
            System.out.println("Is the number a Prime number? No");
        }
        
        sc.close();
    }
}