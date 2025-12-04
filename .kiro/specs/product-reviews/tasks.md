# Implementation Plan

- [x] 1. Create database migration and schema





  - [x] 1.1 Create migration file for product_reviews table


    - Create `src/migrations/YYYYMMDDHHMMSS_create_product_reviews.sql`
    - Define table with id, product_id, user_id, rating, comment, created_at, updated_at
    - Add CHECK constraint for rating (1-5)
    - Add UNIQUE constraint on (product_id, user_id)
    - Create indexes for product_id, user_id, rating, created_at
    - _Requirements: 8.1, 8.2_

- [ ] 2. Implement repository layer
  - [ ] 2.1 Create product-reviews.repo.js with core CRUD functions
    - Implement createReview, getReviewById, updateReview, deleteReview
    - Implement getReviewsByProductId with pagination
    - Implement getReviewsByUserId with pagination
    - Implement getProductRatingSummary aggregation query
    - Implement checkExistingReview for duplicate detection
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1_
  - [ ] 2.2 Write property test for rating summary calculation
    - **Property 6: Rating summary calculation**
    - **Validates: Requirements 3.1, 3.3**
  - [ ] 2.3 Write property test for pagination correctness
    - **Property 5: Pagination correctness**
    - **Validates: Requirements 2.4**

- [ ] 3. Implement service layer
  - [ ] 3.1 Create product-reviews.service.js with business logic
    - Implement createReview with validation (rating range, product exists)
    - Implement comment sanitization (trim, truncate to 2000 chars)
    - Implement getReviewsByProductId with sorting
    - Implement getProductRatingSummary
    - Implement updateReview with ownership check
    - Implement deleteReview with ownership check and summary update
    - Implement getReviewsByUserId
    - Implement admin functions (getAllReviews, adminDeleteReview)
    - _Requirements: 1.1, 1.2, 1.4, 2.1, 3.1, 4.1, 4.2, 5.1, 5.2, 5.4, 6.1, 7.1, 7.2_
  - [ ] 3.2 Write property test for create review returns correct data
    - **Property 1: Create review returns correct data**
    - **Validates: Requirements 1.1, 1.5**
  - [ ] 3.3 Write property test for invalid rating rejection
    - **Property 2: Invalid rating rejection**
    - **Validates: Requirements 1.2**
  - [ ] 3.4 Write property test for comment sanitization
    - **Property 3: Comment sanitization**
    - **Validates: Requirements 1.4**
  - [ ] 3.5 Write property test for ownership validation
    - **Property 8: Ownership validation**
    - **Validates: Requirements 4.2, 5.2**

- [ ] 4. Implement validation schemas
  - [ ] 4.1 Add Zod schemas for product reviews in validations.js
    - Create createProductReviewSchema (product_id, rating 1-5, optional comment)
    - Create updateProductReviewSchema (optional rating, optional comment, at least one required)
    - Create productReviewQuerySchema (limit, offset, product_id filter, rating filter)
    - _Requirements: 1.2, 2.4, 7.1_

- [ ] 5. Checkpoint
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement controller layer
  - [ ] 6.1 Create product-reviews.controller.js with request handlers
    - Implement createProductReview handler
    - Implement getProductReviews handler
    - Implement getProductRatingSummary handler
    - Implement getMyProductReviews handler
    - Implement getProductReview handler
    - Implement updateProductReview handler
    - Implement deleteProductReview handler
    - Implement adminGetAllReviews handler
    - Implement adminDeleteReview handler
    - _Requirements: 1.1, 2.1, 2.2, 3.1, 4.1, 5.1, 6.1, 7.1, 7.2_
  - [ ] 6.2 Write property test for date serialization format
    - **Property 12: Date serialization format**
    - **Validates: Requirements 8.3**

- [ ] 7. Implement routes
  - [ ] 7.1 Create product-reviews.routes.js with all endpoints
    - POST / - Create review (auth required)
    - GET /product/:productId - Get product reviews (public)
    - GET /product/:productId/summary - Get rating summary (public)
    - GET /my-reviews - Get user's reviews (auth required)
    - GET /:id - Get specific review (auth required)
    - PUT /:id - Update review (auth required)
    - DELETE /:id - Delete review (auth required)
    - GET /admin/all - Admin get all reviews (admin role required)
    - DELETE /admin/:id - Admin delete review (admin role required)
    - Apply rate limiting to create endpoint
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 7.1, 7.2_
  - [ ] 7.2 Register routes in main app
    - Import and mount product-reviews routes in src/app.js
    - _Requirements: All_

- [ ] 8. Implement remaining property tests
  - [ ] 8.1 Write property test for reviews sorted by date descending
    - **Property 4: Reviews sorted by date descending**
    - **Validates: Requirements 2.1**
  - [ ] 8.2 Write property test for update persists changes
    - **Property 7: Update persists changes**
    - **Validates: Requirements 4.1, 4.4**
  - [ ] 8.3 Write property test for delete removes review and updates summary
    - **Property 9: Delete removes review and updates summary**
    - **Validates: Requirements 5.1, 5.4, 7.3**
  - [ ] 8.4 Write property test for user reviews filtered correctly
    - **Property 10: User reviews filtered correctly**
    - **Validates: Requirements 6.1, 6.2**
  - [ ] 8.5 Write property test for admin filtering
    - **Property 11: Admin filtering**
    - **Validates: Requirements 7.1**

- [ ] 9. Final Checkpoint




  - Ensure all tests pass, ask the user if questions arise.
