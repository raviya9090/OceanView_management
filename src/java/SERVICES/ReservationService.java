package SERVICES;

import DAO.ReservationDAO;
import DAO.RoomDAO;
import MODELS.Reservation;
import MODELS.Room;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.Collections;
import java.util.List;

/**
 * ReservationService - Business logic for all Reservation operations
 * @author Ashen Samarasekera
 */
public class ReservationService {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    // ─────────────────────────────────────────────
    // CREATE — Guest books a room
    // ─────────────────────────────────────────────

    /**
     * Book a room. Validates dates, checks availability,
     * calculates nights + total, saves reservation,
     * then marks the room as Occupied.
     */
    public boolean addReservation(String userIdStr, String roomIdStr,
                                  String checkInStr, String checkOutStr) {
        try {
            int userId  = Integer.parseInt(userIdStr.trim());
            int roomId  = Integer.parseInt(roomIdStr.trim());
            Date checkIn  = Date.valueOf(checkInStr.trim());
            Date checkOut = Date.valueOf(checkOutStr.trim());

            if (!checkOut.after(checkIn)) return false;

            Room room = roomDAO.getRoomById(roomId);
            if (room == null || !"Available".equalsIgnoreCase(room.getAvailability())) return false;

            long diffMs = checkOut.getTime() - checkIn.getTime();
            int nights  = (int) (diffMs / (1000L * 60 * 60 * 24));
            BigDecimal total = room.getPricePerNight().multiply(new BigDecimal(nights));

            Reservation reservation = new Reservation();
            reservation.setUserId(userId);
            reservation.setRoomId(roomId);
            reservation.setCheckInDate(checkIn);
            reservation.setCheckOutDate(checkOut);
            reservation.setNumberOfNights(nights);
            reservation.setTotalAmount(total);
            reservation.setPaymentStatus("Pending");

            boolean saved = reservationDAO.addReservation(reservation);
            if (saved) roomDAO.updateRoomAvailability(roomId, "Occupied");
            return saved;

        } catch (Exception e) {
            System.err.println("ReservationService.addReservation: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // READ
    // ─────────────────────────────────────────────

    public List<Reservation> getAllReservations() {
        return reservationDAO.getAllReservations();
    }

    public List<Reservation> getReservationsByUserId(int userId) {
        return reservationDAO.getReservationsByUserId(userId);
    }

    public Reservation getReservationById(int id) {
        return reservationDAO.getReservationById(id);
    }

    // ─────────────────────────────────────────────
    // UPDATE — Admin edits a reservation
    // ─────────────────────────────────────────────

    public boolean updateReservation(String reservationIdStr, String userIdStr,
                                     String roomIdStr, String checkInStr,
                                     String checkOutStr, String paymentStatus) {
        try {
            int reservationId = Integer.parseInt(reservationIdStr.trim());
            int userId  = Integer.parseInt(userIdStr.trim());
            int roomId  = Integer.parseInt(roomIdStr.trim());
            Date checkIn  = Date.valueOf(checkInStr.trim());
            Date checkOut = Date.valueOf(checkOutStr.trim());
            if (!checkOut.after(checkIn)) return false;

            Room room = roomDAO.getRoomById(roomId);
            if (room == null) return false;

            long diffMs = checkOut.getTime() - checkIn.getTime();
            int nights  = (int) (diffMs / (1000L * 60 * 60 * 24));
            BigDecimal total = room.getPricePerNight().multiply(new BigDecimal(nights));

            Reservation res = new Reservation();
            res.setReservationId(reservationId);
            res.setUserId(userId);
            res.setRoomId(roomId);
            res.setCheckInDate(checkIn);
            res.setCheckOutDate(checkOut);
            res.setNumberOfNights(nights);
            res.setTotalAmount(total);
            res.setPaymentStatus(paymentStatus != null ? paymentStatus.trim() : "Pending");

            return reservationDAO.updateReservation(res);

        } catch (Exception e) {
            System.err.println("ReservationService.updateReservation: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // DELETE — Admin deletes and frees room
    // ─────────────────────────────────────────────

    public boolean deleteReservation(String idStr) {
        try {
            int id = Integer.parseInt(idStr.trim());
            Reservation res = reservationDAO.getReservationById(id);
            boolean deleted = reservationDAO.deleteReservation(id);
            if (deleted && res != null) {
                roomDAO.updateRoomAvailability(res.getRoomId(), "Available");
            }
            return deleted;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // CANCEL — Guest cancels own reservation
    // ─────────────────────────────────────────────

    public boolean cancelReservation(String reservationIdStr, String userIdStr) {
        try {
            int reservationId = Integer.parseInt(reservationIdStr.trim());
            int userId        = Integer.parseInt(userIdStr.trim());
            boolean cancelled = reservationDAO.cancelReservation(reservationId, userId);
            if (cancelled) {
                Reservation res = reservationDAO.getReservationById(reservationId);
                if (res != null) roomDAO.updateRoomAvailability(res.getRoomId(), "Available");
            }
            return cancelled;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // COUNTS for stats cards
    // ─────────────────────────────────────────────

    public int getTotalReservationCount() {
        return reservationDAO.getAllReservations().size();
    }
}