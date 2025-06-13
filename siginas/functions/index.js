const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();
const firestore = admin.firestore();

// 1. Cloud Function: Ketika laporan harian baru ditambahkan, perbarui status siswa
exports.onDailyReportAdded = onDocumentCreated(
  // Path dokumen yang akan dipantau
  "users/{schoolUid}/students/{studentId}/daily_reports/{reportId}",
  async (event) => {
    const schoolUid = event.params.schoolUid;
    const studentId = event.params.studentId;
    const snapshot = event.data;

    // Pastikan dokumen ada (tidak null)
    if (!snapshot) {
      console.log("No data associated with the event.");
      return null;
    }

    const studentRef = firestore.collection("users").doc(schoolUid).collection("students").doc(studentId);

    try {
      await studentRef.update({ has_reported_today: true });
      console.log(`Updated has_reported_today to true for student ${studentId} in school ${schoolUid}`);
    } catch (error) {
      console.error(`Error updating has_reported_today for student ${studentId}:`, error);
      throw new Error(`Failed to update has_reported_today for student ${studentId}`);
    }
    return null;
  }
);

// 2. Cloud Function: Jadwal reset harian setiap tengah malam
exports.resetDailyReportStatus = onSchedule(
  {
    // Konfigurasi jadwal: setiap hari pada pukul 17:00 UTC (00:00 WIB/Jakarta)
    schedule: "0 17 * * *",
    timeZone: "Asia/Jakarta",
  },
  async (context) => {
    console.log("Running daily reset for has_reported_today...");

    try {
      const usersRef = firestore.collection("users");
      const schoolsSnapshot = await usersRef.where("role", "==", "school").get();

      if (schoolsSnapshot.empty) {
        console.log("No school users found to reset.");
        return null;
      }

      const batch = firestore.batch();
      let studentsUpdated = 0;

      for (const schoolDoc of schoolsSnapshot.docs) {
        const schoolUid = schoolDoc.id;
        const studentsRef = firestore.collection("users").doc(schoolUid).collection("students");

        const studentsSnapshot = await studentsRef.get();

        if (studentsSnapshot.empty) {
          console.log(`No students found for school: ${schoolUid}, skipping.`);
          continue;
        }

        for (const studentDoc of studentsSnapshot.docs) {
          // Hanya update jika statusnya true, untuk menghemat operasi write
          if (studentDoc.data().has_reported_today === true) {
            batch.update(studentDoc.ref, { has_reported_today: false });
            studentsUpdated++;
          }
        }
      }

      if (studentsUpdated > 0) {
        await batch.commit();
        console.log(`Successfully reset has_reported_today for ${studentsUpdated} students.`);
      } else {
        console.log("No students needed resetting (or no students found with true status).");
      }

      return null;
    } catch (error) {
      console.error("Error resetting daily report status:", error);
      throw new Error("Failed to reset daily report status");
    }
  }
);
