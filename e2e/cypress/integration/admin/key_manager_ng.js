describe("keymanagerng", () => {
  let randomNumber
  let createSecret
  let deleteSecret
  let deleteContainer
  let iRandomNum
  let sPassPhraseSecretName
  let sPrivateSecretName
  let sPublicSecretName
  let sCertificateSecretName
  let sSymmetricSecretName
  let sSecretPayload
  let sSecretUuid
  let sPassPhraseSecretUuid
  let sContainerUuid
  let sGenericContainerName
  let sCertificateContainerName
  let sRsaContainerName

  before(() => {
    createSecret = (sSecretName, iSecretType, iPayloadContentType) => {
      cy.contains("New Secret").click()
      cy.get("[data-target='name-text-input']").type(sSecretName)
      //Select 'symmetric' as Secret Type
      cy.get("select[name='secretType']").select(iSecretType, { force: true })
      cy.get("[data-target='payload-text-area']").type(sSecretPayload)
      cy.get("select[name='payloadContentType']").select(iPayloadContentType, {
        force: true,
      })
      //Save the new secret
      cy.get("[data-target='save-secret-btn']").click()

      //Find the newly created secret in secrets table
      cy.contains("Secrets").should("have.lengthOf", 1)
      cy.get("[data-target='secret-list-data-grid']").should("have.lengthOf", 1)
      cy.get("[data-target=" + sSecretName + "]").should("have.lengthOf", 1)
    }

    deleteSecret = (sSecretName) => {
      cy.get("[data-target=" + sSecretName + "]")
        .find("[data-target='secret-uuid']")
        .then(($identifier) => {
          sSecretUuid = $identifier[0].innerText
          cy.get("[data-target=" + sSecretUuid + "]").click()
          cy.contains("Remove").should("have.lengthOf", 1)
          cy.contains("Cancel").should("have.lengthOf", 1)
          cy.contains(
            "Are you sure you want to delete the secret " + sSecretName + "?"
          ).click()
          cy.contains("Remove").click()
          cy.contains(
            "The secret " + sSecretUuid + " is successfully deleted."
          ).should("have.lengthOf", 1)
        })
    }
    deleteContainer = (sContainerName) => {
      cy.get("[data-target=" + sContainerName + "]")
        .find("[data-target='container-uuid']")
        .then(($identifier) => {
          sContainerUuid = $identifier[0].innerText
          // cy.get("[data-target=" + sContainerName + "]")
          //   .find("[data-target='container-dropdown-btn']")
          //   .click()
          cy.get("[data-target=" + sContainerUuid + "]").click()
          cy.contains("Remove").should("have.lengthOf", 1)
          cy.contains("Cancel").should("have.lengthOf", 1)
          cy.contains(
            "Are you sure you want to delete the container " +
              sContainerName +
              "?"
          ).click()
          cy.contains("Remove").click()
          cy.contains(
            "The container " + sContainerUuid + " is successfully deleted."
          ).should("have.lengthOf", 1)
        })
    }
  })

  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    randomNumber = () => Cypress._.random(0, 1e6)
    iRandomNum = randomNumber()
    sPassPhraseSecretName = `test-pass-phrase-secret-${iRandomNum}`
    sPrivateSecretName = `test-private-secret-${iRandomNum}`
    sPublicSecretName = `test-public-secret-${iRandomNum}`
    sCertificateSecretName = `test-certificate-secret-${iRandomNum}`
    sSymmetricSecretName = `test-symmetric-secret-${iRandomNum}`
    sSecretPayload = `test secret`
    sGenericContainerName = `test-generic-container-${iRandomNum}`
    sCertificateContainerName = `test-certificate-container-${iRandomNum}`
    sRsaContainerName = `test-rsa-container-${iRandomNum}`
  })

  // it("open key manager and create a new 'Passphrase' secret and delete it", () => {
  //   cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/keymanagerng/secrets`)

  //   //Check domain and project names and titles
  //   cy.contains("cc3test").should("have.lengthOf", 1)
  //   cy.contains("admin").should("have.lengthOf", 1)
  //   cy.contains("Key Manager").should("have.lengthOf", 1)
  //   cy.contains("Secrets").should("have.lengthOf", 1)
  //   cy.contains(
  //     "This is the new version of Key Manager. If you prefer to use the previous version, click here"
  //   ).should("have.lengthOf", 1)

  //   //navigate to old key manager
  //   cy.get("[data-target='nav-to-old-key-manager']").click()
  //   cy.contains("There is a new version of Key Manager. Try it out").should(
  //     "have.lengthOf",
  //     1
  //   )
  //   //navigate back to the new key manager
  //   cy.get("[data-target='nav-to-new-key-manager']").click()
  //   cy.contains(
  //     "This is the new version of Key Manager. If you prefer to use the previous version, click here"
  //   ).should("have.lengthOf", 1)

  //   //Trying to create a new secret without filling name or payload inputs
  //   cy.contains("New Secret").click()
  //   cy.contains("New Secret").should("have.lengthOf", 1)
  //   cy.get("[data-target='save-secret-btn']").click()
  //   cy.contains("Name can't be empty!")
  //   cy.contains("Secret type can't be empty!")
  //   cy.contains("Payload can't be empty!")
  //   cy.contains("Payload content type can't be empty!")

  //   //Fill necessary fields to create a new secret
  //   cy.get("[data-target='name-text-input']").type(sPassPhraseSecretName)
  //   cy.get("select[name='secretType']").select(4, { force: true })
  //   cy.get("[data-target='payload-text-area']").type(sSecretPayload)
  //   cy.get("select[name='payloadContentType']").select(2, {
  //     force: true,
  //   })
  //   cy.get("[data-target='save-secret-btn']").click()

  //   //Find the newly created secret in secrets table
  //   cy.get("[data-target=" + sPassPhraseSecretName + "]").should(
  //     "have.lengthOf",
  //     1
  //   )

  //   //Delete the newly created secret
  //   deleteSecret(sPassPhraseSecretName)
  // })

  // it("Create a new 'Symmetric' secret, check 'Payload Content Encoding' is available, then delete the newly created secret", () => {
  //   cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/keymanagerng/secrets`)

  //   //Create a new secret with symmetric type
  //   createSecret(sSymmetricSecretName, 6, 1)

  //   //Delete the newly created secret
  //   deleteSecret(sSymmetricSecretName)
  // })

  it("Create new containers with 'Generic' and 'Certificate' container types and delete them afterwards", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/keymanagerng/secrets`)

    //1. Create a new container with container type 'Generic' and delete it afterwards
    //Create one Passphrase secret to be selected in the new container
    createSecret(sPassPhraseSecretName, 6, 1)

    //Find uuid of newly created secret to be able to find it in the new container dialog
    // cy.get("[data-target=" + sPassPhraseSecretName + "]")
    //   .find("[data-target='secret-uuid']")
    //   .then(($identifier) => {
    //     sPassPhraseSecretUuid = $identifier[0].innerText

    //Select Containers
    cy.contains("Containers").click()

    //Create a new container
    cy.contains("New Container").click()
    cy.contains("New Container").should("have.lengthOf", 1)

    //Check that creating a new container without giving it a name is not possible
    // cy.get("[data-target='create-new-container']").click()
    // cy.contains("Secret_refs: can't be blank")

    // //Fill out name of the new container
    // cy.get('[placeHolder="Enter name"]').type(sGenericContainerName)

    // //Select a secret to add it to the new container
    // cy.contains("Select secrets")
    // cy.contains("Select secrets").click()
    // cy.get("input[value=" + sPassPhraseSecretUuid + "]").click()
    // cy.get("[data-target='add-secret-to-a-new-generic-container']").click()

    // // Create the new container
    // cy.get("[data-target='create-new-container']").click()
    // cy.get("[data-target=" + sGenericContainerName + "]").should(
    //   "have.lengthOf",
    //   1
    // )

    //Find the newly created container to delete it
    // deleteContainer(sGenericContainerName)
    // })

    // //2. Create a new container with container type 'Certificate' and delete it afterwards
    // cy.get("[data-target='secrets']").click()
    // cy.contains("Available Secrets")
    // //Create one Certificate secret to be selected in the new container
    // createSecret(sCertificateSecretName, 1)

    // //Select Containers and create a container
    // cy.get("[data-target='containers']").click()
    // cy.contains("Available Containers")
    // cy.contains("New Container").click()
    // cy.contains("New Container").should("have.lengthOf", 1)

    // //Fill out name of the new container
    // cy.get("[placeHolder='Enter name']").type(sCertificateContainerName)
    // //Select 'Certificate' as the container type
    // cy.get("[data-target='container-type-in-new-container-dialog']").select(1)
    // cy.get("[data-target='certificate-input']").select(1)

    // //Try to create the new container
    // cy.get("[data-target='create-new-container']").click()
    // cy.get("[data-target=" + sCertificateContainerName + "]").should(
    //   "have.lengthOf",
    //   1
    // )

    // //Delete the newly created container
    // deleteContainer(sCertificateContainerName)

    // //Select Secrets
    // cy.get("[data-target='secrets']").click()
    // cy.contains("Available Secrets")

    // //Delete the newly created secrets
    // deleteSecret(sCertificateSecretName)

    // //Click on containers and again come back to secrets because performing
    // // deletion on two secrets following by each other could not successful
    // cy.get("[data-target='containers']").click()
    // cy.contains("Available Containers")
    // cy.get("[data-target='secrets']").click()
    // cy.contains("Available Secrets")

    // deleteSecret(sPassPhraseSecretName)
  })

  // it("Create new containers with 'Rsa' container type and delete it afterwards", () => {
  //   //Create a new container with container type 'Rsa' and delete it afterwards
  //   cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/keymanagerng/secrets`)

  //   //Create three secrets with types passphrase, public and private to be selected in the new container
  //   //1. Create passphrase secret
  //   createSecret(sPassPhraseSecretName, 3)

  //   //2. Create private secret
  //   createSecret(sPrivateSecretName, 4)

  //   //3. Create public secret
  //   createSecret(sPublicSecretName, 5)

  //   //Select Containers
  //   cy.get("[data-target='containers']").click()
  //   cy.contains("Available Containers")

  //   //Create a new container with container type 'Rsa' and delete it afterwards
  //   cy.contains("New Container").click()
  //   cy.contains("New Container").should("have.lengthOf", 1)
  //   //Fill out name of the new container
  //   cy.get("[target='new-container-name']").type(sRsaContainerName)

  //   //Select 'Rsa' as the container type
  //   cy.get("[data-target='container-type-in-new-container-dialog']").select(3)
  //   cy.contains("Private key").should("have.lengthOf", 1)
  //   cy.get(
  //     "[data-target='private-key-input-in-new-rsa-container-dialog']"
  //   ).select(1)
  //   cy.contains("Private key passphrase").should("have.lengthOf", 1)
  //   cy.get("[data-target='secret-input-in-new-rsa-container-dialog']").select(1)
  //   cy.contains("Public key").should("have.lengthOf", 1)
  //   cy.get(
  //     "[data-target='public-key-input-in-new-rsa-container-dialog']"
  //   ).select(1)

  //   //Try to create the new container
  //   cy.get("[data-target='create-new-container']").click()
  //   cy.get("[data-target=" + sRsaContainerName + "]").should("have.lengthOf", 1)

  //   //Find the newly created container to delete it
  //   deleteContainer(sRsaContainerName)

  //   //Delete the newly created secret
  //   //Select Secrets tab
  //   cy.get("[data-target='secrets']").click()
  //   cy.contains("Available Secrets")
  //   // Delete the newly created passphrase secret
  //   deleteSecret(sPassPhraseSecretName)

  //   //Click on containers and again come back to secrets
  //   cy.get("[data-target='containers']").click()
  //   cy.contains("Available Containers")
  //   cy.get("[data-target='secrets']").click()
  //   cy.contains("Available Secrets")

  //   // Delete the newly created public secret
  //   deleteSecret(sPublicSecretName)

  //   //Click on containers and again come back to secrets
  //   cy.get("[data-target='containers']").click()
  //   cy.contains("Available Containers")
  //   cy.get("[data-target='secrets']").click()
  //   cy.contains("Available Secrets")

  //   // Delete the newly created private secret
  //   deleteSecret(sPrivateSecretName)
  // })

  after(() => {
    deleteSecret = null
    deleteContainer = null
    createSecret = null
  })

  afterEach(() => {
    randomNumber = null
    iRandomNum = null
    sPassPhraseSecretName = null
    sPrivateSecretName = null
    sPublicSecretName = null
    sCertificateSecretName = null
    sSymmetricSecretName = null
    sSecretPayload = null
    sPassPhraseSecretUuid = null
    sSecretUuid = null
    sContainerUuid = null
    sGenericContainerName = null
    sCertificateContainerName = null
    sRsaContainerName = null
  })
})
