import fs from 'fs/promises';
import path from 'path';

const dataDir = path.resolve(process.cwd(), 'assets/data');
const outputFilePath = path.join(dataDir, 'categories.json');

async function generateCategories() {
  try {
    const files = await fs.readdir(dataDir);
    const restaurantFiles = files.filter(file => file.startsWith('restaurants_') && file.endsWith('.json'));

    const categories = {};

    for (const file of restaurantFiles) {
      const filePath = path.join(dataDir, file);
      const fileContent = await fs.readFile(filePath, 'utf-8');
      const restaurants = JSON.parse(fileContent);

      for (const restaurant of restaurants) {
        const parts = restaurant.category.split(' > ');
        if (parts.length < 2) continue;

        const level2 = parts[1];
        const level3 = parts.length > 2 ? parts[2] : null;

        if (!categories[level2]) {
          categories[level2] = [];
        }

        if (level3 && !categories[level2].includes(level3)) {
          categories[level2].push(level3);
        }
      }
    }

    // 3차 카테고리가 없는 2차 카테고리를 위해, 2차 카테고리 자체를 3차 목록에 추가
    for (const level2 in categories) {
        if (categories[level2].length === 0) {
            categories[level2].push(level2);
        }
    }


    await fs.writeFile(outputFilePath, JSON.stringify(categories, null, 2));
    console.log(`✅ Categories successfully generated at ${outputFilePath}`);

  } catch (error) {
    console.error('Error generating categories:', error);
  }
}

generateCategories();
