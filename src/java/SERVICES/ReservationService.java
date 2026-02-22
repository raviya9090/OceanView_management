package SERVICES;

import DAO.ReservationDAO;
import DAO.RoomDAO;
import MODELS.Reservation;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

public class ReservationService {
    private final ReservationDAO dao = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    public boolean createReservation(int userId, int roomId,
                                     String checkInStr, String checkOutStr,
                                     BigDecimal pricePerNight) {
        try {
            Date checkIn  = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            long diff = checkOut.getTime() - checkIn.getTime();
            int nights = (int) (diff / (1000 * 60 * 60 * 24));
            if (nights <= 0) return false;

            BigDecimal total = pricePerNight.multiply(BigDecimal.valueOf(nights));

            Reservation r = new Reservation();
            r.setUserId(userId);
            r.setRoomId(roomId);
            r.setCheckInDate(checkIn);
            r.setCheckOutDate(checkOut);
            r.setNumberOfNights(nights);
            r.setTotalAmount(total);
            r.setPaymentStatus("Pending");

            boolean created = dao.createReservation(r);

            // ── After successful reservation, mark room as Occupied ──────────
            if (created) {
                roomDAO.updateRoomAvailability(roomId, "Occupied");
            }

            return created;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Reservation> getAllReservations() {
        return dao.getAllReservations();
    }

    public List<Reservation> getReservationsByUserId(int userId) {
        return dao.getReservationsByUserId(userId);
    }

    public Reservation getReservationById(int id) {
        return dao.getReservationById(id);
    }

    public boolean updateReservation(int reservationId, int roomId,
                                     String checkInStr, String checkOutStr,
                                     BigDecimal pricePerNight, String paymentStatus) {
        try {
            Date checkIn  = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            long diff = checkOut.getTime() - checkIn.getTime();
            int nights = (int) (diff / (1000 * 60 * 60 * 24));
            if (nights <= 0) return false;

            BigDecimal total = pricePerNight.multiply(BigDecimal.valueOf(nights));

            Reservation r = new Reservation();
            r.setReservationId(reservationId);
            r.setRoomId(roomId);
            r.setCheckInDate(checkIn);
            r.setCheckOutDate(checkOut);
            r.setNumberOfNights(nights);
            r.setTotalAmount(total);
            r.setPaymentStatus(paymentStatus);

            boolean updated = dao.updateReservation(r);

            // ── If admin marks as Cancelled, free the room ───────────────────
            if (updated && "Cancelled".equalsIgnoreCase(paymentStatus)) {
                roomDAO.updateRoomAvailability(roomId, "Available");
            }
            // ── If admin marks as Paid, keep room Occupied ───────────────────
            if (updated && "Paid".equalsIgnoreCase(paymentStatus)) {
                roomDAO.updateRoomAvailability(roomId, "Occupied");
            }

            return updated;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelReservation(int reservationId) {
        // ── Fetch reservation first so we know which room to free ────────────
        Reservation existing = dao.getReservationById(reservationId);
        boolean cancelled = dao.updatePaymentStatus(reservationId, "Cancelled");
        if (cancelled && existing != null) {
            roomDAO.updateRoomAvailability(existing.getRoomId(), "Available");
        }
        return cancelled;
    }

    public boolean deleteReservation(int reservationId) {
        // ── Free the room when a reservation is hard-deleted ─────────────────
        Reservation existing = dao.getReservationById(reservationId);
        boolean deleted = dao.deleteReservation(reservationId);
        if (deleted && existing != null) {
            roomDAO.updateRoomAvailability(existing.getRoomId(), "Available");
        }
        return deleted;
    }

    public int getTotalReservationCount() {
        return dao.getTotalReservationCount();
    }

    public int getTotalGuestCount() {
        return dao.getTotalGuestCount();
    }
}