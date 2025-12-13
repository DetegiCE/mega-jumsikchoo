// npm i axios
import axios from "axios";
import { writeFileSync } from "fs";
import * as fs from 'fs/promises';
import path from 'path';

const REST_API_KEY = process.env.KAKAO_REST_KEY;

async function fetchAllRestaurants({ lng, lat, radius }) {
  const out = [];
  let page = 1;

  while (true) {
    const res = await axios.get("https://dapi.kakao.com/v2/local/search/category.json", {
      headers: { Authorization: `KakaoAK ${REST_API_KEY}` },
      params: {
        category_group_code: "FD6",
        x: lng,
        y: lat,
        radius,
        page,
        size: 15,
      },
    });

    const { documents, meta } = res.data;

    for (const p of documents) {
      out.push({
        id: p.id,
        name: p.place_name,
        category: p.category_name,
        phone: p.phone,
        address: p.address_name,
        roadAddress: p.road_address_name,
        x: p.x,
        y: p.y,
        url: p.place_url,
      });
    }

    if (meta.is_end) break;
    page += 1;
  }

  const uniq = new Map(out.map((p) => [p.id, p]));
  return [...uniq.values()];
}

function getBoundingBox(lat, lng, radius) {
  const R = 6371e3;
  const radLat = (lat * Math.PI) / 180;
  const radLng = (lng * Math.PI) / 180;
  const radDist = radius / R;

  const minLat = radLat - radDist;
  const maxLat = radLat + radDist;

  const deltaLng = Math.asin(Math.sin(radDist) / Math.cos(radLat));
  const minLng = radLng - deltaLng;
  const maxLng = radLng + deltaLng;

  return {
    minLat: (minLat * 180) / Math.PI,
    maxLat: (maxLat * 180) / Math.PI,
    minLng: (minLng * 180) / Math.PI,
    maxLng: (maxLng * 180) / Math.PI,
  };
}

async function tiledFetch({ lat, lng, radius }) {
  const TILE_COUNT = 3;
  const box = getBoundingBox(lat, lng, radius);
  const latStep = (box.maxLat - box.minLat) / TILE_COUNT;
  const lngStep = (box.maxLng - box.minLng) / TILE_COUNT;

  const allRestaurants = [];
  for (let i = 0; i < TILE_COUNT; i++) {
    for (let j = 0; j < TILE_COUNT; j++) {
      const tileCenterLat = box.minLat + latStep * (i + 0.5);
      const tileCenterLng = box.minLng + lngStep * (j + 0.5);
      const tileRadius = Math.sqrt(Math.pow(latStep * 111111, 2) + Math.pow(lngStep * 111111 * Math.cos((tileCenterLat * Math.PI) / 180), 2)) / 2;

      console.log(`Fetching tile (${i}, ${j}) at ${tileCenterLat}, ${tileCenterLng} with radius ${Math.round(tileRadius)}m`);
      const restaurants = await fetchAllRestaurants({
        lat: tileCenterLat,
        lng: tileCenterLng,
        radius: Math.min(20000, Math.round(tileRadius)),
      });
      allRestaurants.push(...restaurants);
    }
  }

  const uniq = new Map(allRestaurants.map((p) => [p.id, p]));
  return [...uniq.values()];
}

async function main() {
  const center = { lat: 37.499391908186475, lng: 127.02794421854804 };
  const radii = [100, 250, 400, 600, 800, 1000];
  const allFetchedIds = new Set();

  for (const radius of radii) {
    try {
      const data = await tiledFetch({ ...center, radius });
      const newData = data.filter((p) => !allFetchedIds.has(p.id));
      newData.forEach((p) => allFetchedIds.add(p.id));

      const filename = `restaurants_${radius}m.json`;
      console.log(`[${radius}m] count:`, newData.length);
      writeFileSync(filename, JSON.stringify(newData, null, 2));
      console.log(`'${filename}' 파일에 저장되었습니다.`);
    } catch (error) {
      console.error(`[${radius}m] 검색 중 오류 발생:`, error);
    }
  }
}

// main();

export async function getCategories() {
  const dataDir = '.';
  const files = await fs.readdir(dataDir);
  const jsonFiles = files.filter(file => file.startsWith('restaurants_') && file.endsWith('.json'));

  let allCategories = new Set();

  for (const file of jsonFiles) {
    const filePath = path.join(dataDir, file);
    const content = await fs.readFile(filePath, 'utf-8');
    const data = JSON.parse(content);
    data.forEach(item => {
      if (item.category) {
        item.category.split('>').forEach(c => allCategories.add(c.trim()));
      }
    });
  }

  const sortedCategories = [...allCategories].sort();
  console.log(sortedCategories.join('\n'));
}

getCategories();
