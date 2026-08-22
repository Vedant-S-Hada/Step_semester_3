import java.util.Scanner;

public class GCD {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter number1: ");
        int number1 = sc.nextInt();
        System.out.print("Enter number2: ");
        int number2 = sc.nextInt();

        int temp1 = number1;
        int temp2 = number2;

        // Euclidean algorithm implementation[cite: 1]
        while (number2 != 0) {
            int remainder = number1 % number2;
            number1 = number2;
            number2 = remainder;
        }

        // number1 now holds the GCD[cite: 1]
        System.out.println("The GCD of " + temp1 + " and " + temp2 + " is " + number1);

        sc.close();
    }
}