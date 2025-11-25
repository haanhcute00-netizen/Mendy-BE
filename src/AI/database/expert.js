import { query } from "../../config/db.js";
import levenshtein from "js-levenshtein";

// ============ 1. Chuẩn data DB =============
// Must match keywords in prompt.js
export const DB_KEYWORDS = [
  // Mental Health
  "anxiety", "depression", "stress", "panic-attack", "trauma", "grief", "ptsd",

  // Relationships
  "relationship", "family-conflict", "marriage", "divorce", "breakup", "parenting",

  // Life & Career
  "career", "productivity", "interview", "burnout", "work-life-balance",

  // Self Development
  "self-esteem", "confidence", "life-coaching", "healing", "mindfulness",

  // Specific Issues
  "sleep-issues", "eating-disorder", "addiction", "anger-management"
];

export const vnToDB = {
  // Mental Health
  "lo âu": "anxiety",
  "bồn chồn": "anxiety",
  "trầm cảm": "depression",
  "buồn bã": "depression",
  "u uất": "depression",
  "căng thẳng": "stress",
  "áp lực": "stress",
  "hoảng loạn": "panic-attack",
  "chấn thương": "trauma",
  "mất mát": "grief",
  "tang thương": "grief",

  // Relationships
  "mối quan hệ": "relationship",
  "tình cảm": "relationship",
  "yêu đương": "relationship",
  "xung đột gia đình": "family-conflict",
  "gia đình": "family-conflict",
  "hôn nhân": "marriage",
  "ly hôn": "divorce",
  "chia tay": "breakup",
  "nuôi con": "parenting",
  "làm cha mẹ": "parenting",

  // Life & Career
  "sự nghiệp": "career",
  "công việc": "career",
  "nghề nghiệp": "career",
  "năng suất": "productivity",
  "quản lý thời gian": "productivity",
  "phỏng vấn": "interview",
  "kiệt sức": "burnout",
  "cân bằng": "work-life-balance",

  // Self Development
  "tự tin": "self-esteem",
  "tự trọng": "self-esteem",
  "định hướng cuộc sống": "life-coaching",
  "chữa lành": "healing",
  "thiền": "mindfulness",
  "chánh niệm": "mindfulness",

  // Specific Issues
  "mất ngủ": "sleep-issues",
  "giấc ngủ": "sleep-issues",
  "rối loạn ăn uống": "eating-disorder",
  "nghiện": "addiction",
  "giận dữ": "anger-management",
  "nóng giận": "anger-management"
};

export const synonyms = {
  anxiety: ["worry", "overthinking", "nervous", "fear"],
  depression: ["sad", "hopeless", "melancholy"],
  stress: ["pressure", "tense", "overwhelmed"],
  "panic-attack": ["panic", "anxiety attack"],
  trauma: ["ptsd", "traumatic"],
  grief: ["loss", "mourning", "bereavement"],

  relationship: ["love", "connection", "partner"],
  "family-conflict": ["family issue", "family problem"],
  marriage: ["married life", "spouse"],
  divorce: ["separation", "split"],
  breakup: ["break up", "ended relationship"],
  parenting: ["raising kids", "child-rearing"],

  career: ["job", "work", "profession"],
  productivity: ["time management", "efficiency"],
  interview: ["job interview", "job application"],
  burnout: ["exhaustion", "fatigue"],
  "work-life-balance": ["balance"],

  "self-esteem": ["confidence", "self-worth"],
  confidence: ["self-confidence"],
  "life-coaching": ["guidance", "life direction"],
  healing: ["emotional support", "recovery"],
  mindfulness: ["meditation", "awareness"],

  "sleep-issues": ["insomnia", "sleep problem"],
  "eating-disorder": ["anorexia", "bulimia"],
  addiction: ["substance abuse", "dependency"],
  "anger-management": ["anger issues", "aggression"]
};

// ============ 2. Normalize keyword =============
export function normalizeKeywords(aiKeywords) {
  const result = new Set();

  aiKeywords.forEach((k) => {
    const lower = k.toLowerCase().trim();

    // match exact in DB
    if (DB_KEYWORDS.includes(lower)) {
      result.add(lower);
      return;
    }

    // match via VN mapping
    if (vnToDB[lower]) {
      result.add(vnToDB[lower]);
      return;
    }

    // match via synonyms (fuzzy)
    DB_KEYWORDS.forEach((dbKey) => {
      const synList = synonyms[dbKey] || [];
      synList.forEach((syn) => {
        if (levenshtein(lower, syn) <= 2) {
          result.add(dbKey);
        }
      });
    });
  });

  return Array.from(result);
}

// ============ 3. Search Expert =============
export async function findExpertsByKeywordsSmart(aiKeywords) {
  const normalized = normalizeKeywords(aiKeywords);

  if (normalized.length === 0) {
    // fallback: đề xuất chuyên gia top rating
    const fallback = await query(`
      SELECT ep.id, ep.price_per_session, ep.rating_avg, up.display_name, up.avatar_url
      FROM app.expert_profiles ep
      JOIN app.user_profiles up ON ep.user_id = up.user_id
      ORDER BY ep.rating_avg DESC
      LIMIT 5;
    `);
    return { experts: fallback.rows, matchedKeywords: [] };
  }

  const sql = `
    SELECT ep.id, ep.price_per_session, ep.rating_avg,
           up.display_name, up.avatar_url, ep.intro
    FROM app.expert_profiles ep
    JOIN app.user_profiles up ON ep.user_id = up.user_id
    JOIN app.expert_status es ON ep.id = es.expert_id
    WHERE ep.specialties && $1
    ORDER BY ep.rating_avg DESC, es.active_score DESC
    LIMIT 5;
  `;
  const result = await query(sql, [normalized]);

  return { experts: result.rows, matchedKeywords: normalized };
}
