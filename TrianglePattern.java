import java.util.Scanner;

public class TrianglePattern {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter rows: ");
        int rows = sc.nextInt();

        System.out.println("The right-angled triangle pattern for " + rows + " rows is:");
        
        // Outer loop for rows[cite: 1]
        for (int i = 1; i <= rows; i++) {
            // Inner loop for stars in each column[cite: 1]
            for (int j = 1; j <= i; j++) {
                System.out.print("*");
            }
            // Move to the next line after finishing the row[cite: 1]
            System.out.println();
        }

        sc.close();
    }
}