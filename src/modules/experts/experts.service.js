// src/services/experts.service.js - Enhanced expert service with comprehensive business logic
import * as ExpertsRepo from "./experts.repo.js";
import * as UsersRepo from "../users/users.repo.js";


// Basic expert profile operations
export async function getExpertProfile(userId) {
  try {
    const expert = await ExpertsRepo.getExpertProfile(userId);
    
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Get additional expert data
    const [skills, experience, education, certifications, media, status, performance] = await Promise.all([
      ExpertsRepo.getExpertSkills(expert.id),
      ExpertsRepo.getExpertExperience(expert.id),
      ExpertsRepo.getExpertEducation(expert.id),
      ExpertsRepo.getExpertCertifications(expert.id),
      ExpertsRepo.getExpertMedia(expert.id),
      ExpertsRepo.getExpertStatus(expert.id),
      ExpertsRepo.getExpertPerformance(expert.id)
    ]);
    
    return {
      ...expert,
      skills,
      experience,
      education,
      certifications,
      media,
      status,
      performance
    };
  } catch (error) {
    throw error;
  }
}

export async function updateExpertProfile(userId, updateData) {
  try {
    // Validate user is an expert
    const user = await UsersRepo.getProfileByUserId(userId);
    if (!user || user.role_primary !== 'EXPERT') {
      throw Object.assign(new Error("Only experts can update expert profile"), { status: 403 });
    }
    
    // Get current profile to check if exists
    let currentProfile = await ExpertsRepo.getExpertProfile(userId);
    
    if (!currentProfile) {
      // Create new expert profile if doesn't exist
      currentProfile = await ExpertsRepo.createExpertProfile({
        userId,
        specialties: updateData.specialties || [],
        pricePerSession: updateData.price_per_session || 0,
        intro: updateData.intro || '',
        kycStatus: 'PENDING'
      });
    } else {
      // Update existing profile
      currentProfile = await ExpertsRepo.updateExpertProfile({
        userId,
        specialties: updateData.specialties !== undefined ? updateData.specialties : currentProfile.specialties,
        pricePerSession: updateData.price_per_session !== undefined ? updateData.price_per_session : currentProfile.price_per_session,
        intro: updateData.intro !== undefined ? updateData.intro : currentProfile.intro
      });
    }
    
    return currentProfile;
  } catch (error) {
    throw error;
  }
}

// Skills management
export async function addExpertSkill(userId, skillData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.addExpertSkill({
      expertId: expert.id,
      name: skillData.name,
      category: skillData.category
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertSkill(userId, skillId, skillData) {
  try {
    // Verify ownership
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Check if skill belongs to expert
    const skills = await ExpertsRepo.getExpertSkills(expert.id);
    const skillExists = skills.some(skill => skill.id === skillId);
    
    if (!skillExists) {
      throw Object.assign(new Error("Skill not found or doesn't belong to expert"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertSkill({
      id: skillId,
      name: skillData.name,
      category: skillData.category
    });
  } catch (error) {
    throw error;
  }
}

export async function removeExpertSkill(userId, skillId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.removeExpertSkill({
      expertId: expert.id,
      skillId
    });
  } catch (error) {
    throw error;
  }
}

// Experience management
export async function addExpertExperience(userId, experienceData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.addExpertExperience({
      expertId: expert.id,
      position: experienceData.position,
      organization: experienceData.organization,
      years: experienceData.years,
      description: experienceData.description,
      startYear: experienceData.start_year,
      endYear: experienceData.end_year
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertExperience(userId, experienceId, experienceData) {
  try {
    // Verify ownership
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Check if experience belongs to expert
    const experiences = await ExpertsRepo.getExpertExperience(expert.id);
    const experienceExists = experiences.some(exp => exp.id === experienceId);
    
    if (!experienceExists) {
      throw Object.assign(new Error("Experience not found or doesn't belong to expert"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertExperience({
      id: experienceId,
      position: experienceData.position,
      organization: experienceData.organization,
      years: experienceData.years,
      description: experienceData.description,
      startYear: experienceData.start_year,
      endYear: experienceData.end_year
    });
  } catch (error) {
    throw error;
  }
}

export async function removeExpertExperience(userId, experienceId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.removeExpertExperience({
      id: experienceId,
      expertId: expert.id
    });
  } catch (error) {
    throw error;
  }
}

// Education management
export async function addExpertEducation(userId, educationData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.addExpertEducation({
      expertId: expert.id,
      degree: educationData.degree,
      institution: educationData.institution,
      yearCompleted: educationData.year_completed,
      description: educationData.description
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertEducation(userId, educationId, educationData) {
  try {
    // Verify ownership
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Check if education belongs to expert
    const education = await ExpertsRepo.getExpertEducation(expert.id);
    const educationExists = education.some(edu => edu.id === educationId);
    
    if (!educationExists) {
      throw Object.assign(new Error("Education not found or doesn't belong to expert"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertEducation({
      id: educationId,
      degree: educationData.degree,
      institution: educationData.institution,
      yearCompleted: educationData.year_completed,
      description: educationData.description
    });
  } catch (error) {
    throw error;
  }
}

export async function removeExpertEducation(userId, educationId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.removeExpertEducation({
      id: educationId,
      expertId: expert.id
    });
  } catch (error) {
    throw error;
  }
}

// Certifications management
export async function addExpertCertification(userId, certificationData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.addExpertCertification({
      expertId: expert.id,
      certificateName: certificationData.certificate_name,
      issuingOrg: certificationData.issuing_org,
      issuedAt: certificationData.issued_at,
      expiresAt: certificationData.expires_at,
      credentialUrl: certificationData.credential_url
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertCertification(userId, certificationId, certificationData) {
  try {
    // Verify ownership
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Check if certification belongs to expert
    const certifications = await ExpertsRepo.getExpertCertifications(expert.id);
    const certificationExists = certifications.some(cert => cert.id === certificationId);
    
    if (!certificationExists) {
      throw Object.assign(new Error("Certification not found or doesn't belong to expert"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertCertification({
      id: certificationId,
      certificateName: certificationData.certificate_name,
      issuingOrg: certificationData.issuing_org,
      issuedAt: certificationData.issued_at,
      expiresAt: certificationData.expires_at,
      credentialUrl: certificationData.credential_url
    });
  } catch (error) {
    throw error;
  }
}

export async function removeExpertCertification(userId, certificationId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.removeExpertCertification({
      id: certificationId,
      expertId: expert.id
    });
  } catch (error) {
    throw error;
  }
}

// Availability management
export async function getExpertAvailability(userId, dateFrom, dateTo) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.getExpertAvailability(expert.id, dateFrom, dateTo);
  } catch (error) {
    throw error;
  }
}

export async function addExpertAvailability(userId, availabilityData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.addExpertAvailability({
      expertId: expert.id,
      startAt: availabilityData.start_at,
      endAt: availabilityData.end_at,
      isRecurring: availabilityData.is_recurring,
      recurringPattern: availabilityData.recurring_pattern
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertAvailability(userId, availabilityId, availabilityData) {
  try {
    // Verify ownership
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Check if availability belongs to expert
    const availabilities = await ExpertsRepo.getExpertAvailability(expert.id);
    const availabilityExists = availabilities.some(avail => avail.id === availabilityId);
    
    if (!availabilityExists) {
      throw Object.assign(new Error("Availability not found or doesn't belong to expert"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertAvailability({
      id: availabilityId,
      startAt: availabilityData.start_at,
      endAt: availabilityData.end_at,
      isRecurring: availabilityData.is_recurring,
      recurringPattern: availabilityData.recurring_pattern
    });
  } catch (error) {
    throw error;
  }
}

export async function removeExpertAvailability(userId, availabilityId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.removeExpertAvailability({
      id: availabilityId,
      expertId: expert.id
    });
  } catch (error) {
    throw error;
  }
}

// Target audience and domains management
export async function updateExpertTargetAudience(userId, audienceIds) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertTargetAudience({
      expertId: expert.id,
      audienceIds
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertDomains(userId, domainIds) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertDomains({
      expertId: expert.id,
      domainIds
    });
  } catch (error) {
    throw error;
  }
}

// Media/portfolio management
export async function getExpertMedia(userId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.getExpertMedia(expert.id);
  } catch (error) {
    throw error;
  }
}

export async function addExpertMedia(userId, mediaData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.addExpertMedia({
      expertId: expert.id,
      mediaType: mediaData.media_type,
      url: mediaData.url,
      title: mediaData.title,
      description: mediaData.description
    });
  } catch (error) {
    throw error;
  }
}

export async function updateExpertMedia(userId, mediaId, mediaData) {
  try {
    // Verify ownership
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    // Check if media belongs to expert
    const media = await ExpertsRepo.getExpertMedia(expert.id);
    const mediaExists = media.some(m => m.id === mediaId);
    
    if (!mediaExists) {
      throw Object.assign(new Error("Media not found or doesn't belong to expert"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertMedia({
      id: mediaId,
      mediaType: mediaData.media_type,
      url: mediaData.url,
      title: mediaData.title,
      description: mediaData.description
    });
  } catch (error) {
    throw error;
  }
}

export async function removeExpertMedia(userId, mediaId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.removeExpertMedia({
      id: mediaId,
      expertId: expert.id
    });
  } catch (error) {
    throw error;
  }
}

// Expert status management
export async function updateExpertStatus(userId, statusData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertStatus({
      expertId: expert.id,
      isAvailable: statusData.is_available,
      currentStatus: statusData.current_status,
      statusMessage: statusData.status_message
    });
  } catch (error) {
    throw error;
  }
}

// Expert search and listing
export async function searchExperts(searchParams) {
  try {
    return await ExpertsRepo.searchExperts(searchParams);
  } catch (error) {
    throw error;
  }
}

export async function getExpertById(expertId) {
  try {
    const expert = await ExpertsRepo.getExpertById(expertId);
    
    if (!expert) {
      throw Object.assign(new Error("Expert not found"), { status: 404 });
    }
    
    return expert;
  } catch (error) {
    throw error;
  }
}

// Expert statistics and analytics
export async function getExpertStats(userId) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.getExpertStats(expert.id);
  } catch (error) {
    throw error;
  }
}

// Expert performance tracking
export async function updateExpertPerformance(userId, performanceData) {
  try {
    // Get expert profile
    const expert = await ExpertsRepo.getExpertProfile(userId);
    if (!expert) {
      throw Object.assign(new Error("Expert profile not found"), { status: 404 });
    }
    
    return await ExpertsRepo.updateExpertPerformance({
      expertId: expert.id,
      responseTimeAvg: performanceData.response_time_avg,
      sessionCompletionRate: performanceData.session_completion_rate,
      satisfactionScore: performanceData.satisfaction_score
    });
  } catch (error) {
    throw error;
  }
}

// Expert validation and verification
export async function validateExpertProfile(userId) {
  try {
    const expert = await ExpertsRepo.getExpertProfile(userId);
    
    if (!expert) {
      return {
        isValid: false,
        errors: ["Expert profile not found"],
        completionPercentage: 0
      };
    }
    
    const errors = [];
    let completionPercentage = 0;
    const totalFields = 8;
    let completedFields = 0;
    
    // Check profile completeness
    if (expert.specialties && expert.specialties.length > 0) {
      completedFields++;
    } else {
      errors.push("Specialties are required");
    }
    
    if (expert.intro && expert.intro.length >= 50) {
      completedFields++;
    } else {
      errors.push("Introduction must be at least 50 characters");
    }
    
    if (expert.price_per_session > 0) {
      completedFields++;
    } else {
      errors.push("Price per session must be greater than 0");
    }
    
    // Check additional sections
    const [skills, experience, education, certifications] = await Promise.all([
      ExpertsRepo.getExpertSkills(expert.id),
      ExpertsRepo.getExpertExperience(expert.id),
      ExpertsRepo.getExpertEducation(expert.id),
      ExpertsRepo.getExpertCertifications(expert.id)
    ]);
    
    if (skills.length > 0) completedFields++;
    else errors.push("At least one skill is required");
    
    if (experience.length > 0) completedFields++;
    else errors.push("At least one experience entry is required");
    
    if (education.length > 0) completedFields++;
    else errors.push("At least one education entry is required");
    
    if (certifications.length > 0) completedFields++;
    else errors.push("At least one certification is recommended");
    
    completionPercentage = Math.round((completedFields / totalFields) * 100);
    
    return {
      isValid: errors.length === 0,
      errors,
      completionPercentage,
      isComplete: completionPercentage === 100
    };
  } catch (error) {
    throw error;
  }
}
