// src/controllers/experts.controller.js - Enhanced expert controller with comprehensive endpoints
import { asyncHandler } from "../../utils/asyncHandler.js";
import { success, failure } from "../../utils/response.js";
import * as ExpertsService from "./experts.service.js";

// Basic expert profile operations
export const getMyExpertProfile = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  try {
    const expertProfile = await ExpertsService.getExpertProfile(userId);

    return success(res, "experts.profile.retrieved", expertProfile);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "PROFILE_RETRIEVAL_FAILED",
      status: error.status || 500
    });
  }
});

export const updateMyExpertProfile = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const updateData = req.body;

  try {
    const updatedProfile = await ExpertsService.updateExpertProfile(userId, updateData);

    return success(res, "experts.profile.updated", updatedProfile);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "PROFILE_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

// Skills management
export const addSkill = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const skillData = req.body;

  try {
    const skill = await ExpertsService.addExpertSkill(userId, skillData);

    return success(res, "experts.skills.added", skill);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "SKILL_ADD_FAILED",
      status: error.status || 500
    });
  }
});

export const updateSkill = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { skillId } = req.params;
  const skillData = req.body;

  try {
    const updatedSkill = await ExpertsService.updateExpertSkill(userId, parseInt(skillId), skillData);

    return success(res, "experts.skills.updated", updatedSkill);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "SKILL_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const removeSkill = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { skillId } = req.params;

  try {
    await ExpertsService.removeExpertSkill(userId, parseInt(skillId));

    return success(res, "experts.skills.deleted");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "SKILL_REMOVE_FAILED",
      status: error.status || 500
    });
  }
});

// Experience management
export const addExperience = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const experienceData = req.body;

  try {
    const experience = await ExpertsService.addExpertExperience(userId, experienceData);

    return success(res, "experts.experience.added", experience);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EXPERIENCE_ADD_FAILED",
      status: error.status || 500
    });
  }
});

export const updateExperience = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { experienceId } = req.params;
  const experienceData = req.body;

  try {
    const updatedExperience = await ExpertsService.updateExpertExperience(userId, parseInt(experienceId), experienceData);

    return success(res, "experts.experience.updated", updatedExperience);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EXPERIENCE_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const removeExperience = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { experienceId } = req.params;

  try {
    await ExpertsService.removeExpertExperience(userId, parseInt(experienceId));

    return success(res, "experts.experience.deleted");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EXPERIENCE_REMOVE_FAILED",
      status: error.status || 500
    });
  }
});

// Education management
export const addEducation = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const educationData = req.body;

  try {
    const education = await ExpertsService.addExpertEducation(userId, educationData);

    return success(res, "experts.education.added", education);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EDUCATION_ADD_FAILED",
      status: error.status || 500
    });
  }
});

export const updateEducation = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { educationId } = req.params;
  const educationData = req.body;

  try {
    const updatedEducation = await ExpertsService.updateExpertEducation(userId, parseInt(educationId), educationData);

    return success(res, "experts.education.updated", updatedEducation);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EDUCATION_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const removeEducation = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { educationId } = req.params;

  try {
    await ExpertsService.removeExpertEducation(userId, parseInt(educationId));

    return success(res, "experts.education.deleted");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EDUCATION_REMOVE_FAILED",
      status: error.status || 500
    });
  }
});

// Certifications management
export const addCertification = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const certificationData = req.body;

  try {
    const certification = await ExpertsService.addExpertCertification(userId, certificationData);

    return success(res, "experts.certifications.added", certification);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "CERTIFICATION_ADD_FAILED",
      status: error.status || 500
    });
  }
});

export const updateCertification = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { certificationId } = req.params;
  const certificationData = req.body;

  try {
    const updatedCertification = await ExpertsService.updateExpertCertification(userId, parseInt(certificationId), certificationData);

    return success(res, "experts.certifications.updated", updatedCertification);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "CERTIFICATION_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const removeCertification = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { certificationId } = req.params;

  try {
    await ExpertsService.removeExpertCertification(userId, parseInt(certificationId));

    return success(res, "experts.certifications.deleted");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "CERTIFICATION_REMOVE_FAILED",
      status: error.status || 500
    });
  }
});

// Availability management
export const getMyAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { date_from, date_to } = req.query;

  try {
    const availability = await ExpertsService.getExpertAvailability(userId, date_from, date_to);

    return success(res, "experts.availability.retrieved", availability);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "AVAILABILITY_RETRIEVAL_FAILED",
      status: error.status || 500
    });
  }
});

export const addAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const availabilityData = req.body;

  try {
    const availability = await ExpertsService.addExpertAvailability(userId, availabilityData);

    return success(res, "experts.availability.set", availability);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "AVAILABILITY_ADD_FAILED",
      status: error.status || 500
    });
  }
});

export const updateAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { availabilityId } = req.params;
  const availabilityData = req.body;

  try {
    const updatedAvailability = await ExpertsService.updateExpertAvailability(userId, parseInt(availabilityId), availabilityData);

    return success(res, "experts.availability.set", updatedAvailability);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "AVAILABILITY_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const removeAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { availabilityId } = req.params;

  try {
    await ExpertsService.removeExpertAvailability(userId, parseInt(availabilityId));

    return success(res, "experts.availability.deleted");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "AVAILABILITY_REMOVE_FAILED",
      status: error.status || 500
    });
  }
});

// Target audience and domains management
export const updateTargetAudience = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { audience_ids } = req.body;

  try {
    await ExpertsService.updateExpertTargetAudience(userId, audience_ids);

    return success(res, "experts.audience.updated");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "TARGET_AUDIENCE_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const updateDomains = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { domain_ids } = req.body;

  try {
    await ExpertsService.updateExpertDomains(userId, domain_ids);

    return success(res, "experts.domains.updated");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "DOMAINS_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

// Media/portfolio management
export const getMyMedia = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  try {
    const media = await ExpertsService.getExpertMedia(userId);

    return success(res, "experts.media.retrieved", media);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "MEDIA_RETRIEVAL_FAILED",
      status: error.status || 500
    });
  }
});

export const addMedia = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const mediaData = req.body;

  try {
    const media = await ExpertsService.addExpertMedia(userId, mediaData);

    return success(res, "experts.media.added", media);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "MEDIA_ADD_FAILED",
      status: error.status || 500
    });
  }
});

export const updateMedia = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { mediaId } = req.params;
  const mediaData = req.body;

  try {
    const updatedMedia = await ExpertsService.updateExpertMedia(userId, parseInt(mediaId), mediaData);

    return success(res, "experts.media.updated", updatedMedia);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "MEDIA_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

export const removeMedia = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { mediaId } = req.params;

  try {
    await ExpertsService.removeExpertMedia(userId, parseInt(mediaId));

    return success(res, "experts.media.removed");
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "MEDIA_REMOVE_FAILED",
      status: error.status || 500
    });
  }
});

// Expert status management
export const updateMyStatus = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const statusData = req.body;

  try {
    const updatedStatus = await ExpertsService.updateExpertStatus(userId, statusData);

    return success(res, "experts.status.updated", updatedStatus);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "STATUS_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});

// Expert search and listing (public endpoints)
export const searchExperts = asyncHandler(async (req, res) => {
  const searchParams = {
    ...req.query,
    page: parseInt(req.query.page) || 1,
    limit: parseInt(req.query.limit) || 20
  };

  try {
    const result = await ExpertsService.searchExperts(searchParams);

    return success(res, "experts.search.success", result);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EXPERTS_SEARCH_FAILED",
      status: error.status || 500
    });
  }
});

export const getExpertById = asyncHandler(async (req, res) => {
  const { expertId } = req.params;

  try {
    const expert = await ExpertsService.getExpertById(parseInt(expertId));

    return success(res, "experts.profile.retrieved", expert);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "EXPERT_RETRIEVAL_FAILED",
      status: error.status || 500
    });
  }
});

// Expert statistics and analytics
export const getMyStats = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  try {
    const stats = await ExpertsService.getExpertStats(userId);

    return success(res, "experts.stats.retrieved", stats);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "STATS_RETRIEVAL_FAILED",
      status: error.status || 500
    });
  }
});

// Expert validation and verification
export const validateMyProfile = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  try {
    const validation = await ExpertsService.validateExpertProfile(userId);

    return success(res, "experts.validation.success", validation);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "VALIDATION_FAILED",
      status: error.status || 500
    });
  }
});

// Expert performance tracking
export const updateMyPerformance = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const performanceData = req.body;

  try {
    const updatedPerformance = await ExpertsService.updateExpertPerformance(userId, performanceData);

    return success(res, "experts.performance.updated", updatedPerformance);
  } catch (error) {
    return failure(res, error.message, {
      code: error.code || "PERFORMANCE_UPDATE_FAILED",
      status: error.status || 500
    });
  }
});
