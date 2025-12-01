// src/routes/experts.routes.js - Enhanced expert routes with comprehensive endpoints
import { Router } from "express";
import { auth } from "../../middlewares/auth.js";
import { validateExpertData, validateExpertQuery } from "../../utils/expertValidations.js";
import { expertSchemas, expertQuerySchemas } from "../../utils/expertValidations.js";
import * as ExpertsController from "./experts.controller.js";

const router = Router();

// Apply authentication middleware to all expert routes
router.use(auth);

// Basic expert profile routes
router.get("/profile", ExpertsController.getMyExpertProfile);
router.put("/profile",
  validateExpertData(expertSchemas.updateProfile),
  ExpertsController.updateMyExpertProfile
);

// Skills management routes
router.post("/skills",
  validateExpertData(expertSchemas.addSkill),
  ExpertsController.addSkill
);
router.put("/skills/:skillId",
  validateExpertData(expertSchemas.updateSkill),
  ExpertsController.updateSkill
);
router.delete("/skills/:skillId", ExpertsController.removeSkill);

// Experience management routes
router.post("/experience",
  validateExpertData(expertSchemas.addExperience),
  ExpertsController.addExperience
);
router.put("/experience/:experienceId",
  validateExpertData(expertSchemas.updateExperience),
  ExpertsController.updateExperience
);
router.delete("/experience/:experienceId", ExpertsController.removeExperience);

// Education management routes
router.post("/education",
  validateExpertData(expertSchemas.addEducation),
  ExpertsController.addEducation
);
router.put("/education/:educationId",
  validateExpertData(expertSchemas.updateEducation),
  ExpertsController.updateEducation
);
router.delete("/education/:educationId", ExpertsController.removeEducation);

// Certifications management routes
router.post("/certifications",
  validateExpertData(expertSchemas.addCertification),
  ExpertsController.addCertification
);
router.put("/certifications/:certificationId",
  validateExpertData(expertSchemas.updateCertification),
  ExpertsController.updateCertification
);
router.delete("/certifications/:certificationId", ExpertsController.removeCertification);

// Availability management routes
router.get("/availability", ExpertsController.getMyAvailability);
router.post("/availability",
  validateExpertData(expertSchemas.createAvailability),
  ExpertsController.addAvailability
);
router.put("/availability/:availabilityId",
  validateExpertData(expertSchemas.updateAvailability),
  ExpertsController.updateAvailability
);
router.delete("/availability/:availabilityId", ExpertsController.removeAvailability);

// Target audience and domains routes
router.put("/target-audience",
  validateExpertData(expertSchemas.updateTargetAudience),
  ExpertsController.updateTargetAudience
);
router.put("/domains",
  validateExpertData(expertSchemas.updateDomains),
  ExpertsController.updateDomains
);

// Media/portfolio routes
router.get("/media", ExpertsController.getMyMedia);
router.post("/media",
  validateExpertData(expertSchemas.addMedia),
  ExpertsController.addMedia
);
router.put("/media/:mediaId",
  validateExpertData(expertSchemas.updateMedia),
  ExpertsController.updateMedia
);
router.delete("/media/:mediaId", ExpertsController.removeMedia);

// Expert status routes
router.put("/status",
  validateExpertData(expertSchemas.updateStatus),
  ExpertsController.updateMyStatus
);

// Analytics and statistics routes
router.get("/stats", ExpertsController.getMyStats);
router.get("/validate", ExpertsController.validateMyProfile);
router.put("/performance",
  validateExpertData(expertSchemas.updatePerformance),
  ExpertsController.updateMyPerformance
);

// Public expert routes (no authentication required)
// NOTE: Advanced search moved to /api/v1/expert-search module
const publicRouter = Router();

// Basic search (legacy - use /api/v1/expert-search/advanced for full features)
publicRouter.get("/search",
  validateExpertQuery(expertQuerySchemas.searchExperts),
  ExpertsController.searchExperts
);

// Basic expert by ID
publicRouter.get("/:expertId", ExpertsController.getExpertById);

export { router, publicRouter };
