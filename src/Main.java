import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        Map<String, SumCountPair> sumCountMap = new HashMap<>();

        while (scanner.hasNextLine()) {
            System.out.println("Enter key and value: ");
            String line = scanner.nextLine().trim();
            if (line.isEmpty()) {
                break;
            }

            String[] parts = line.split("\\s+");
            if (parts.length != 2) {
                System.err.println("Invalid input format: " + line);
                continue;
            }

            String key = parts[0];
            int value;
            try {
                value = Integer.parseInt(parts[1]);
            } catch (NumberFormatException e) {
                System.err.println("Invalid value: " + parts[1]);
                continue;
            }

            SumCountPair sumCountPair = sumCountMap.getOrDefault(key, new SumCountPair());
            sumCountPair.sum += value;
            sumCountPair.count++;
            sumCountMap.put(key, sumCountPair);
        }

        for (Map.Entry<String, SumCountPair> entry : sumCountMap.entrySet()) {
            String key = entry.getKey();
            SumCountPair sumCountPair = entry.getValue();
            double average = (double) sumCountPair.sum / sumCountPair.count;
            System.out.println("Key: " + key + ", Average: " + average);
        }

        scanner.close();
    }

    static class SumCountPair {
        int sum;
        int count;
    }
}
