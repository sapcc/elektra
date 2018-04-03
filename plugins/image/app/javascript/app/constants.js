export const imageConstants = (type) => ({
  REQUEST_IMAGES:                   `image/os_images/${type}/REQUEST_IMAGES`,
  RECEIVE_IMAGES:                   `image/os_images/${type}/RECEIVE_IMAGES`,
  REQUEST_IMAGE:                    `image/os_images/${type}/REQUEST_IMAGE`,
  REQUEST_IMAGE_FAILURE:            `image/os_images/${type}/REQUEST_IMAGE_FAILURE`,
  REQUEST_IMAGES_FAILURE:           `image/os_images/${type}/REQUEST_IMAGES_FAILURE`,
  RECEIVE_IMAGE:                    `image/os_images/${type}/RECEIVE_IMAGE`,
  REQUEST_DELETE_IMAGE:             `image/os_images/${type}/REQUEST_DELETE_IMAGE`,
  DELETE_IMAGE_FAILURE:             `image/os_images/${type}/DELETE_IMAGE_FAILURE`,
  DELETE_IMAGE_SUCCESS:             `image/os_images/${type}/DELETE_IMAGE_SUCCESS`,
  SET_SEARCH_TERM:                  `image/os_images/${type}/SET_SEARCH_TERM`
})

export const REQUEST_IMAGE_MEMBERS          = 'image/image_members/REQUEST_IMAGE_MEMBERS';
export const RESET_IMAGE_MEMBERS          = 'image/image_members/RESET_IMAGE_MEMBERS';
export const REQUEST_IMAGE_MEMBERS_FAILURE  = 'image/image_members/REQUEST_IMAGE_MEMBERS_FAILURE';
export const RECEIVE_IMAGE_MEMBERS          = 'image/image_members/RECEIVE_IMAGE_MEMBERS';
export const RECEIVE_IMAGE_MEMBER           = 'image/image_members/RECEIVE_IMAGE_MEMBER';
export const REQUEST_DELETE_IMAGE_MEMBER    = 'image/image_members/REQUEST_DELETE_IMAGE_MEMBER';
export const DELETE_IMAGE_MEMBER_FAILURE    = 'image/image_members/DELETE_IMAGE_MEMBER_FAILURE';
export const DELETE_IMAGE_MEMBER            = 'image/image_members/DELETE_IMAGE_MEMBER';
