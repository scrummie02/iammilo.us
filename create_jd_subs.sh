#!/bin/bash
mkfolder() {
  local name="$1"
  local parent="$2"
  local result=$(GOG_ACCOUNT=dain.bentley@gmail.com gog drive mkdir "$name" --parent "$parent" --plain 2>/dev/null)
  local id=$(echo "$result" | awk 'NR==1{print $2}')
  echo "  ✓ $name ($id)" >&2
  echo "$id"
}

# Correct top-level IDs from the 12:14 set
ID_10="1B4jy34T89GYpWA5suCmhm5Zvee-dDBxy"
ID_20="1HNpB6LyRldU948CSmrWb8-GL2S8dP1v_"
ID_30="1-FOh426IQdtVwZ5LoAM5HfauDlhnA_DY"
ID_40="1Az1cKwqToYh7Y5BZJnK4yVW-GcFI_Mhy"
ID_50="1tQmS31qobUD3UMRbE83qPTePLH8EK9bi"
ID_60="10i8C9lhqxBupJUGdj-pP7fNOG3_b7kHs"
ID_70="1TCFkxjlkjTqBLhh4RHb1yGFPBIY_ReK9"

echo "Creating 10-19 subfolders..."
ID_11=$(mkfolder "11 Identity & Legal" "$ID_10")
ID_12=$(mkfolder "12 Medical" "$ID_10")
ID_13=$(mkfolder "13 Education" "$ID_10")
mkfolder "11.01 Licenses & IDs" "$ID_11"
mkfolder "11.02 Certificates" "$ID_11"
mkfolder "11.03 Certifications" "$ID_11"
mkfolder "11.04 Notary" "$ID_11"
mkfolder "11.05 Government & VA Forms" "$ID_11"
mkfolder "12.01 Medical Records" "$ID_12"
mkfolder "12.02 Fitness & Workout" "$ID_12"
mkfolder "13.01 College" "$ID_13"
mkfolder "13.02 Training & Technical" "$ID_13"

echo "Creating 20-29 subfolders..."
ID_21=$(mkfolder "21 Charlotte" "$ID_20")
ID_22=$(mkfolder "22 Divorce & Court" "$ID_20")
mkfolder "23 Dog" "$ID_20"
mkfolder "24 Horses & Equestrian" "$ID_20"
mkfolder "21.01 St Thomas More School" "$ID_21"
mkfolder "22.01 Divorce Documents" "$ID_22"
mkfolder "22.02 Lawyer" "$ID_22"
mkfolder "22.03 Court Documents" "$ID_22"
mkfolder "22.04 Child Support" "$ID_22"

echo "Creating 30-39 subfolders..."
ID_31=$(mkfolder "31 Banking & Accounts" "$ID_30")
ID_32=$(mkfolder "32 Loans & Debt" "$ID_30")
ID_33=$(mkfolder "33 Taxes" "$ID_30")
ID_34=$(mkfolder "34 Retirement" "$ID_30")
ID_35=$(mkfolder "35 Credit" "$ID_30")
mkfolder "31.01 Banking" "$ID_31"
mkfolder "31.02 PayPal" "$ID_31"
mkfolder "31.03 Care Credit" "$ID_31"
mkfolder "32.01 Auto Loan" "$ID_32"
mkfolder "32.02 Student Loan" "$ID_32"
mkfolder "32.03 Loans General" "$ID_32"
mkfolder "33.01 Tax Returns" "$ID_33"
mkfolder "33.02 Tax Documents" "$ID_33"
mkfolder "33.03 LES Pay Stubs" "$ID_33"
mkfolder "34.01 Retirement Plans" "$ID_34"
mkfolder "35.01 Credit Reports" "$ID_35"

echo "Creating 40-49 subfolders..."
ID_41=$(mkfolder "41 Resume & Job Hunt" "$ID_40")
ID_42=$(mkfolder "42 Work Documents" "$ID_40")
ID_43=$(mkfolder "43 IT & Technical" "$ID_40")
mkfolder "41.01 Resume Versions" "$ID_41"
mkfolder "41.02 Job Applications" "$ID_41"
mkfolder "42.01 From Work" "$ID_42"
mkfolder "43.01 Hardware" "$ID_43"
mkfolder "43.02 Technical Docs" "$ID_43"
mkfolder "43.03 Configs & Scripts" "$ID_43"

echo "Creating 50-59 subfolders..."
ID_51=$(mkfolder "51 Housing" "$ID_50")
ID_52=$(mkfolder "52 Vehicle" "$ID_50")
mkfolder "51.01 House Documents" "$ID_51"
mkfolder "51.02 Rental" "$ID_51"
mkfolder "51.03 Bills & Utilities" "$ID_51"
mkfolder "52.01 Vehicle Information" "$ID_52"
mkfolder "52.02 Auto Insurance & Registration" "$ID_52"

echo "Creating 60-69 subfolders..."
ID_61=$(mkfolder "61 Travel" "$ID_60")
mkfolder "61.01 Flight Info" "$ID_61"
mkfolder "61.02 Vacations & Activities" "$ID_61"
mkfolder "62 Recipes" "$ID_60"

echo "Creating 70-79 subfolders..."
mkfolder "71 Personal Notes & Contacts" "$ID_70"
mkfolder "72 Web & Design" "$ID_70"
mkfolder "73 Archive" "$ID_70"
mkfolder "74 Duplicates" "$ID_70"

echo "All done!"
