package com.crimeprevention.crime_backend.core.repo.chat;

import com.crimeprevention.crime_backend.core.model.chat.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface MessageRepository extends JpaRepository<Message, UUID> {

    List<Message> findBySenderId(UUID senderId);

    List<Message> findByReceiverId(UUID receiverId);

    List<Message> findByReportId(UUID reportId);

    Page<Message> findByReceiverIdOrderBySentAtDesc(UUID receiverId, Pageable pageable);

    Page<Message> findBySenderIdOrderBySentAtDesc(UUID senderId, Pageable pageable);

    List<Message> findByReportIdOrderBySentAtAsc(UUID reportId);

}
