Xcode Integration Script
==========================================
Sample Script to automate documentation creation using a run script in Xcode. appledoc can be integrated with Xcode in many ways. Below is one of those ways to get you up and running quickly on Xcode 4.6

1.  Select top of your project in Project Navigator
2.  Click Add Target
3.  Depending on your project type (iOS or OS X) choose Aggregate Template
4.  Create new target. I suggest to call it Documentation
5.  Click on Build Phases and add new Build Phase based on Script
6.  Paste the script below into the script window
7.  Adjust variables in section "Start Constants" as required
8.  Uncomment correct 'target' for your project and comment out another one depending on your project type.
9.  Adjust path to appledoc binary and appledoc's command-line switches if required
10. When you ready to generate a docset from your project, build Documentation target.
11. Docset will be installed into new loction and will become available to Xcode immediately.
12. To refresh Quick Help (ALT+Click) and (ALT+double-click) you may need to restart Xcode to refresh its index cache.

Below is a working script that can be added to the Xcode Build Phases, Run Script

    #appledoc Xcode script  
    # Start constants  
    company="ACME";  
    companyID="com.ACME";
    companyURL="http://ACME.com";
    target="iphoneos";
    #target="macosx";
    outputPath="~/help";
    # End constants
    /usr/local/bin/appledoc \
    --project-name "${PROJECT_NAME}" \
    --project-company "${company}" \
    --company-id "${companyID}" \
    --docset-atom-filename "${company}.atom" \
    --docset-feed-url "${companyURL}/${company}/%DOCSETATOMFILENAME" \
    --docset-package-url "${companyURL}/${company}/%DOCSETPACKAGEFILENAME" \
    --docset-fallback-url "${companyURL}/${company}" \
    --output "${outputPath}" \
    --publish-docset \
    --docset-platform-family "${target}" \
    --logformat xcode \
    --keep-intermediate-files \
    --no-repeat-first-par \
    --no-warn-invalid-crossref \
    --exit-threshold 2 \
    "${PROJECT_DIR}"