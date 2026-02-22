package SERVICES;

import DAO.ReservationDAO;
import MODELS.Reservation;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

public class ReservationService {

    private final ReservationDAO dao = new ReservationDAO();

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

            return dao.createReservation(r);
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
            return dao.updateReservation(r);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelReservation(int reservationId) {
        return dao.updatePaymentStatus(reservationId, "Cancelled");
    }

    public boolean deleteReservation(int reservationId) {
        return dao.deleteReservation(reservationId);
    }

    public int getTotalReservationCount() {
        return dao.getTotalReservationCount();
    }

    public int getTotalGuestCount() {
        return dao.getTotalGuestCount();
    }
}