const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

// Inisialisasi Firebase Admin SDK
admin.initializeApp();
const firestore = admin.firestore();

// 1. Cloud Function: Ketika laporan harian baru ditambahkan
//    - Perbarui status has_reported_today siswa
//    - Inkremen reported_students_today di dokumen sekolah
//    - Perbarui school_has_completed_daily_report di dokumen sekolah
exports.onDailyReportAdded = onDocumentCreated("users/{schoolUid}/students/{studentId}/daily_reports/{reportId}", async (event) => {
  const schoolUid = event.params.schoolUid;
  const studentId = event.params.studentId;
  const snapshot = event.data;

  if (!snapshot) {
    console.log("[onDailyReportAdded] No data associated with the event.");
    return null;
  }

  const studentRef = firestore.collection("users").doc(schoolUid).collection("students").doc(studentId);
  const schoolRef = firestore.collection("users").doc(schoolUid);

  console.log(`[onDailyReportAdded] Processing report for student ${studentId} in school ${schoolUid}`);

  try {
    const schoolDoc = await schoolRef.get();
    if (!schoolDoc.exists) {
      console.error(`[onDailyReportAdded] School document ${schoolUid} not found for report aggregation.`);
      return null;
    }
    const schoolData = schoolDoc.data();
    const totalStudentsInSchool = schoolData.jumlah_siswa || 0;
    const currentReportedStudents = schoolData.reported_students_today || 0;

    const batch = firestore.batch();

    batch.update(studentRef, { has_reported_today: true });
    console.log(`[onDailyReportAdded] Updated has_reported_today to true for student ${studentId}.`);

    const newReportedStudentsToday = currentReportedStudents + 1;
    const schoolHasCompletedReport = newReportedStudentsToday >= totalStudentsInSchool && totalStudentsInSchool > 0;

    batch.update(schoolRef, {
      reported_students_today: admin.firestore.FieldValue.increment(1),
      school_has_completed_daily_report: schoolHasCompletedReport,
      last_daily_report_submitted_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`[onDailyReportAdded] Updated school ${schoolUid} reported_students_today and school_has_completed_daily_report.`);

    await batch.commit();
    console.log(`[onDailyReportAdded] Batch commit successful for daily report. totalStudentsInSchool: ${totalStudentsInSchool}, newReportedStudentsToday: ${newReportedStudentsToday}`);
  } catch (error) {
    console.error(`[onDailyReportAdded] Error processing daily report for student ${studentId} in school ${schoolUid}:`, error);
    throw new Error(`Failed to process daily report: ${error.message}`);
  }
  return null;
});

// 2. Cloud Function: Jadwal reset harian setiap tengah malam (00:00 WIB)
//    - Reset has_reported_today untuk semua siswa
//    - Reset reported_students_today dan school_has_completed_daily_report untuk semua sekolah
//    - Reset total_daily_reports_today di national_stats/Gl14eP7zjqub64AAhWfR
exports.resetDailyReportStatus = onSchedule(
  {
    schedule: "0 17 * * *", // 00:00 WIB (UTC+7, jadi 17:00 UTC)
    timeZone: "Asia/Jakarta", // Pastikan zona waktu sesuai
  },
  async (context) => {
    console.log("[resetDailyReportStatus] Running daily reset for report statuses...");

    try {
      const usersRef = firestore.collection("users");
      const schoolsSnapshot = await usersRef.where("role", "==", "school").get();

      if (schoolsSnapshot.empty) {
        console.log("[resetDailyReportStatus] No school users found to reset.");
        return null;
      }

      const batch = firestore.batch();
      let studentsResetCount = 0;
      let schoolsResetCount = 0;

      for (const schoolDoc of schoolsSnapshot.docs) {
        const schoolUid = schoolDoc.id;
        const studentsRef = firestore.collection("users").doc(schoolUid).collection("students");

        const studentsSnapshot = await studentsRef.get();
        if (!studentsSnapshot.empty) {
          for (const studentDoc of studentsSnapshot.docs) {
            if (studentDoc.data().has_reported_today === true) {
              batch.update(studentDoc.ref, { has_reported_today: false });
              studentsResetCount++;
            }
          }
        }

        if ((schoolDoc.data().reported_students_today || 0) > 0 || schoolDoc.data().school_has_completed_daily_report === true) {
          batch.update(schoolDoc.ref, {
            reported_students_today: 0,
            school_has_completed_daily_report: false,
          });
          schoolsResetCount++;
        }
      }

      const nationalStatsRef = firestore.collection("national_stats").doc("Gl14eP7zjqub64AAhWfR"); // KOREKSI: Menggunakan "Gl14eP7zjqub64AAhWfR"
      batch.set(
        nationalStatsRef,
        {
          total_daily_reports_today: 0, // Reset ke 0
          last_updated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      console.log("[resetDailyReportStatus] Reset total_daily_reports_today in national_stats/Gl14eP7zjqub64AAhWfR to 0.");

      await batch.commit();
      console.log(`[resetDailyReportStatus] Successfully reset has_reported_today for ${studentsResetCount} students and reset status for ${schoolsResetCount} schools.`);

      return null;
    } catch (error) {
      console.error("[resetDailyReportStatus] Error resetting daily report status:", error);
      throw new Error(`Failed to reset daily report status: ${error.message}`);
    }
  }
);

// 3. Cloud Function: Ketika status verifikasi pengguna (sekolah) berubah, perbarui total_schools_registered
exports.onUserVerifiedStatusChange = onDocumentUpdated("users/{userId}", async (event) => {
  if (!event.data) {
    console.log("[onUserVerifiedStatusChange] No data associated with the event.");
    return null;
  }

  const oldValue = event.data.before.data();
  const newValue = event.data.after.data();
  const userId = event.params.userId;

  if (!oldValue || !newValue || !oldValue.role || typeof oldValue.is_verified === "undefined" || typeof newValue.is_verified === "undefined") {
    console.log(`[onUserVerifiedStatusChange] Skipping update for user ${userId}: Missing role or is_verified field.`);
    return null;
  }

  const oldRole = oldValue.role;
  const newRole = newValue.role;
  const oldIsVerified = oldValue.is_verified;
  const newIsVerified = newValue.is_verified;

  const nationalStatsRef = firestore.collection("national_stats").doc("Gl14eP7zjqub64AAhWfR"); // KOREKSI: Menggunakan "Gl14eP7zjqub64AAhWfR"
  let incrementValue = 0;

  if (oldRole === "school" && newRole === "school" && oldIsVerified === false && newIsVerified === true) {
    incrementValue = 1;
    console.log(`[onUserVerifiedStatusChange] User ${userId} (school) changed from unverified to verified. Incrementing total_schools_registered.`);
  } else if (oldRole === "school" && newRole === "school" && oldIsVerified === true && newIsVerified === false) {
    incrementValue = -1;
    console.log(`User ${userId} (school) changed from verified to unverified. Decrementing total_schools_registered.`);
  } else if (newRole === "school" && newIsVerified === true && oldRole !== "school") {
    incrementValue = 1;
    console.log(`User ${userId} role changed to verified school. Incrementing total_schools_registered.`);
  } else if (oldRole === "school" && oldIsVerified === true && newRole !== "school") {
    incrementValue = -1;
    console.log(`User ${userId} role changed from verified school to non-school. Decrementing total_schools_registered.`);
  } else {
    console.log(`Skipping update for user ${userId}: No relevant change in verification status or role.`);
    return null;
  }

  if (incrementValue !== 0) {
    try {
      await nationalStatsRef.set(
        {
          total_schools_registered: admin.firestore.FieldValue.increment(incrementValue),
          last_updated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      console.log(`[onUserVerifiedStatusChange] Successfully updated total_schools_registered by ${incrementValue}.`);
    } catch (error) {
      console.error(`Error updating total_schools_registered for user ${userId}:`, error);
      throw new Error(`Failed to update total_schools_registered`);
    }
  }
  return null;
});

// 4. Cloud Function: Ketika siswa baru ditambahkan, inkremen jumlah_siswa di dokumen sekolah
exports.onStudentAdded = onDocumentCreated("users/{schoolUid}/students/{studentId}", async (event) => {
  const schoolUid = event.params.schoolUid;
  const studentId = event.params.studentId;

  if (!event.data) {
    console.log(`[onStudentAdded] No data for student ${studentId} event.`);
    return null;
  }

  const schoolRef = firestore.collection("users").doc(schoolUid);
  console.log(`[onStudentAdded] Student ${studentId} added to school ${schoolUid}. Incrementing total students.`);

  try {
    await schoolRef.update({
      jumlah_siswa: admin.firestore.FieldValue.increment(1),
      last_updated: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`[onStudentAdded] Successfully incremented jumlah_siswa for school ${schoolUid}.`);
  } catch (error) {
    console.error(`[onStudentAdded] Error incrementing jumlah_siswa for school ${schoolUid}:`, error);
    throw new Error(`Failed to increment jumlah_siswa for school ${schoolUid}`);
  }
  return null;
});

// --- Fungsi BARU: onSchoolDailyReportStatusChange ---
// Ini akan terpicu setiap kali dokumen sekolah (di koleksi 'users') di-update
// Khususnya untuk menghitung 'total_daily_reports_today' nasional
exports.onSchoolDailyReportStatusChange = onDocumentUpdated(
  "users/{schoolUid}", // Pantau perubahan pada dokumen sekolah
  async (event) => {
    if (!event.data) {
      console.log("[onSchoolDailyReportStatusChange] No data associated with the event.");
      return null;
    }

    const oldValue = event.data.before.data();
    const newValue = event.data.after.data();
    const schoolUid = event.params.schoolUid;

    // Pastikan ini adalah dokumen sekolah yang valid dan field yang relevan ada
    if (!oldValue || !newValue || oldValue.role !== "school" || newValue.role !== "school" || typeof oldValue.school_has_completed_daily_report === "undefined" || typeof newValue.school_has_completed_daily_report === "undefined") {
      console.log(`[onSchoolDailyReportStatusChange] Skipping user ${schoolUid}: Not a school or missing daily report status field.`);
      return null;
    }

    const oldSchoolCompleted = oldValue.school_has_completed_daily_report;
    const newSchoolCompleted = newValue.school_has_completed_daily_report;

    console.log(`[onSchoolDailyReportStatusChange] School ${schoolUid} status change from ${oldSchoolCompleted} to ${newSchoolCompleted}.`);

    // Hanya proses jika status 'school_has_completed_daily_report' berubah
    if (oldSchoolCompleted !== newSchoolCompleted) {
      const nationalStatsRef = firestore.collection("national_stats").doc("Gl14eP7zjqub64AAhWfR"); // KOREKSI: Menggunakan "Gl14eP7zjqub64AAhWfR"
      let incrementValue = 0;

      if (oldSchoolCompleted === false && newSchoolCompleted === true) {
        incrementValue = 1; // Sekolah baru saja menyelesaikan laporan harian
        console.log(`[onSchoolDailyReportStatusChange] School ${schoolUid} just completed daily report. Incrementing total_daily_reports_today.`);
      } else if (oldSchoolCompleted === true && newSchoolCompleted === false) {
        // Ini adalah kasus di mana status berubah dari 'true' menjadi 'false'.
        // Ini mungkin terjadi karena reset harian, atau jumlah siswa diubah
        // sehingga membuat sekolah tidak lagi 'selesai'.
        // Kita hanya akan melakukan dekremen jika nilai saat ini lebih dari 0.
        // Gunakan Transaction untuk membaca dan mengupdate agar aman dari race condition.
        try {
          await firestore.runTransaction(async (transaction) => {
            const docSnapshot = await transaction.get(nationalStatsRef);
            const currentTotal = docSnapshot.data()?.total_daily_reports_today || 0;

            if (currentTotal > 0) {
              // Hanya dekremen jika nilai saat ini > 0
              transaction.set(
                nationalStatsRef,
                {
                  total_daily_reports_today: admin.firestore.FieldValue.increment(-1),
                  last_updated: admin.firestore.FieldValue.serverTimestamp(),
                },
                { merge: true }
              );
              console.log(`[onSchoolDailyReportStatusChange] School ${schoolUid} status changed to incomplete. Decrementing total_daily_reports_today (from ${currentTotal}).`);
            } else {
              console.log(`[onSchoolDailyReportStatusChange] Skipping decrement for school ${schoolUid} as total_daily_reports_today is already 0.`);
            }
          });
        } catch (error) {
          console.error(`[onSchoolDailyReportStatusChange] Transaction error updating total_daily_reports_today for school ${schoolUid}:`, error);
          throw new Error(`Failed to update total_daily_reports_today via transaction`);
        }
        return null; // Keluar setelah dekremen (sudah ditangani oleh transaction)
      }

      if (incrementValue !== 0) {
        // Hanya untuk kasus increment (+1)
        try {
          await nationalStatsRef.set(
            {
              total_daily_reports_today: admin.firestore.FieldValue.increment(incrementValue),
              last_updated: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
          console.log(`[onSchoolDailyReportStatusChange] Successfully updated total_daily_reports_today by ${incrementValue}.`);
        } catch (error) {
          console.error(`[onSchoolDailyReportStatusChange] Error updating total_daily_reports_today for school ${schoolUid}:`, error);
          throw new Error(`Failed to update total_daily_reports_today`);
        }
      }
    }
    return null;
  }
);
