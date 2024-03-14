import java.util.*;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        // Масиви для збереження ключів та середніх значень
        String[] keys = new String[10000]; // Максимальна кількість унікальних ключів
        double[] averages = new double[10000]; // Відповідні середні значення

        // Масиви для збереження сум та кількості значень для кожного ключа
        int[] sums = new int[10000];
        int[] counts = new int[10000];

        int index = 0;

        while (scanner.hasNextLine()) {
            String line = scanner.nextLine().trim();
            if (line.isEmpty()) {
                break;
            }

            // Розділити рядок на ключ та значення
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

            // Пошук індексу ключа у вже збережених ключах
            int existingIndex = -1;
            for (int i = 0; i < index; i++) {
                if (keys[i].equals(key)) {
                    existingIndex = i;
                    break;
                }
            }

            // Оновлення суми та кількості для поточного ключа
            if (existingIndex == -1) {
                keys[index] = key;
                sums[index] += value;
                counts[index]++;
                index++;
            } else {
                sums[existingIndex] += value;
                counts[existingIndex]++;
            }
        }

        // Обчислення середніх значень
        for (int i = 0; i < index; i++) {
            averages[i] = (double) sums[i] / counts[i];
        }

        // Сортування ключів за середнім значенням методом бульбашкового сортування
        for (int i = 0; i < index - 1; i++) {
            for (int j = 0; j < index - i - 1; j++) {
                if (averages[j] < averages[j + 1]) {
                    // Обмін ключів
                    String tempKey = keys[j];
                    keys[j] = keys[j + 1];
                    keys[j + 1] = tempKey;

                    // Обмін середніх значень
                    double tempAverage = averages[j];
                    averages[j] = averages[j + 1];
                    averages[j + 1] = tempAverage;
                }
            }
        }

        // Вивести відсортовані ключі
        for (int i = 0; i < index; i++) {
            System.out.println(keys[i]);
        }

        scanner.close();
    }
}
