import { serve } from "std/http";
import { createClient } from "@supabase/supabase-js";

// ───────────────── TYPES ─────────────────

type Role = "user" | "assistant";

type ChatReq = {
  message: string;
  conversation_id?: string;
  history?: Array<{ role: Role; content: string }>;
  context?: {
    city?: string;
    hotel_id?: string;
    room_type_id?: string;
    booking_id?: string;
    check_in?: string;
    check_out?: string;
    guests?: number;
    min_rating?: number;
  };
};

type Intent =
  | "hotel_search"
  | "check_availability"
  | "create_booking"
  | "list_bookings"
  | "cancel_booking"
  | "general_chat";

// ───────────────── HELPERS ─────────────────

async function saveMessage(
  supabase: any,
  userId: string,
  conversationId: string,
  role: "user" | "assistant",
  message: string,
  metadata?: any,
) {
  const { error } = await supabase
    .from("chat_messages")
    .insert({
      user_id: userId,
      conversation_id: conversationId,
      role,
      message,
      metadata: metadata ?? {},
    });

  if (error) {
    console.error("SAVE MESSAGE ERROR:", error);

    throw new Error(error.message);
  }
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function money(v: unknown): string {
  const n = Number(v ?? 0);
  return n.toLocaleString("vi-VN") + "đ";
}

function daysBetween(ci: string, co: string): number {
  const start = new Date(ci + "T00:00:00Z").getTime();
  const end = new Date(co + "T00:00:00Z").getTime();

  return Math.max(
    1,
    Math.round((end - start) / 86400000),
  );
}

function extractDates(text: string): {
  check_in?: string;
  check_out?: string;
} {
  const m = text.match(/\d{4}-\d{2}-\d{2}/g) ?? [];

  if (m.length >= 2) {
    return {
      check_in: m[0]!,
      check_out: m[1]!,
    };
  }

  if (m.length === 1) {
    return {
      check_in: m[0]!,
    };
  }

  return {};
}

function extractCity(text: string): string | null {
  const t = text.toLowerCase();

  const cities: Record<string, string> = {
    "hà nội": "Hà Nội",
    "ha noi": "Hà Nội",
    "đà nẵng": "Đà Nẵng",
    "da nang": "Đà Nẵng",
    "tp hcm": "TP.HCM",
    "hồ chí minh": "TP.HCM",
    "ho chi minh": "TP.HCM",
    "nha trang": "Nha Trang",
    "phú quốc": "Phú Quốc",
    "phu quoc": "Phú Quốc",
    "hội an": "Hội An",
    "hoi an": "Hội An",
  };

  for (const [k, v] of Object.entries(cities)) {
    if (t.includes(k)) return v;
  }

  return null;
}

// ───────────────── INTENT DETECTION ─────────────────

function detectIntent(message: string): Intent {
  const t = message.toLowerCase().trim();

  if (/hủy|cancel/.test(t)) {
    return "cancel_booking";
  }

  if (/booking của tôi|đơn đặt|lịch sử/.test(t)) {
    return "list_bookings";
  }

  if (/đặt phòng|book|đặt ngay/.test(t)) {
    return "create_booking";
  }

  if (/còn phòng|phòng trống|available/.test(t)) {
    return "check_availability";
  }

  if (
    /khách sạn|hotel|resort|tìm ks|tìm khách sạn/.test(t)
  ) {
    return "hotel_search";
  }

  return "general_chat";
}

// ───────────────── GROQ ─────────────────

async function callGroq(args: {
  apiKey: string;
  model: string;
  systemPrompt: string;
  userMessage: string;
}) {
  const resp = await fetch(
    "https://api.groq.com/openai/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${args.apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: args.model,
        temperature: 0.4,
        messages: [
          {
            role: "system",
            content: args.systemPrompt,
          },
          {
            role: "user",
            content: args.userMessage,
          },
        ],
      }),
    },
  );

  if (!resp.ok) {
    throw new Error(await resp.text());
  }

  const j = await resp.json();

  return (
    j?.choices?.[0]?.message?.content ??
    "Xin lỗi, mình chưa hiểu."
  );
}

// ───────────────── MAIN ─────────────────

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return json({ ok: true });
  }

  try {
    // ───── ENV ─────

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const groqKey = Deno.env.get("GROQ_API_KEY")!;
    const groqModel =
      Deno.env.get("GROQ_MODEL") ??
      "llama-3.3-70b-versatile";

    // ───── AUTH ─────

    const authHeader =
      req.headers.get("Authorization") ?? "";

    const supabase = createClient(
      supabaseUrl,
      anonKey,
      {
        global: {
          headers: {
            Authorization: authHeader,
          },
        },
      },
    );

    const { data: userData } =
      await supabase.auth.getUser();

    if (!userData?.user) {
      return json(
        {
          reply: "🔒 Bạn cần đăng nhập.",
        },
        401,
      );
    }

    const user = userData.user;

    // ───── BODY ─────

    const body = (await req.json()) as ChatReq;

    const message =
      body.message?.trim() ?? "";

    if (!message) {
      return json(
        {
          reply: "Bạn chưa nhập nội dung 😊",
        },
        400,
      );
    }

    // ───── CONVERSATION ─────

   let conversationId: string =
    body.conversation_id ?? "";
    if (!conversationId) {
      const {
        data: conv,
        error: convError,
      } = await supabase
        .from("conversations")
        .insert({
          user_id: user.id,
          title: message.slice(0, 50),
        })
        .select()
        .single();

      if (convError || !conv) {
        return json(
          {
            reply:
              "❌ Không tạo được conversation.",
          },
          500,
        );
      }

      conversationId = conv.id;
    }

    // ───── SAVE USER MESSAGE ─────

    await saveMessage(
      supabase,
      user.id,
      conversationId,
      "user",
      message,
      {
        type: "user_message",
      },
    );

    // ───── CONTEXT ─────

    const ctx = body.context ?? {};

    const dates = extractDates(message);

    const hotelId =
      ctx.hotel_id ?? null;

    const roomTypeId =
      ctx.room_type_id ?? null;

    const bookingId =
      ctx.booking_id ?? null;

    const check_in =
      ctx.check_in ?? dates.check_in;

    const check_out =
      ctx.check_out ?? dates.check_out;

    const guests =
      Number(ctx.guests ?? 1);

    // ───── DETECT INTENT ─────

    const intent =
      detectIntent(message);

    // ───────────────── HOTEL SEARCH ─────────────────

    if (intent === "hotel_search") {
      const city =
        ctx.city ??
        extractCity(message);

      let query = supabase
        .from("hotels")
        .select(`
          id,
          name,
          city,
          address,
          star_rating,
          thumbnail_url
        `)
        .limit(10)
        .order("star_rating", {
          ascending: false,
        });

      if (city) {
        query = query.ilike(
          "city",
          `%${city}%`,
        );
      }

      const {
        data,
        error,
      } = await query;

      if (error) {
        return json({
          reply:
            "❌ Lỗi tìm khách sạn: " +
            error.message,
        });
      }

      const hotels = data ?? [];

      const assistantReply =
        hotels.length === 0
          ? city
            ? `😔 Không tìm thấy khách sạn ở ${city}.`
            : "Bạn muốn tìm khách sạn ở đâu?"
          : `🏨 Tìm thấy ${hotels.length} khách sạn:\n\n` +
            hotels
              .map(
                (h: any) =>
                  `• **${h.name}** ${"⭐".repeat(
                    h.star_rating ?? 0,
                  )}\n📍 ${h.city} - ${
                    h.address ?? ""
                  }`,
              )
              .join("\n\n");

      await saveMessage(
        supabase,
        user.id,
        conversationId,
        "assistant",
        assistantReply,
        {
          type: "hotel_search",
          hotels,
        },
      );

      return json({
        conversation_id:
          conversationId,
        type: "hotel_search",
        hotels,
        reply: assistantReply,
      });
    }

    // ───────────────── CHECK AVAILABILITY ─────────────────

    if (intent === "check_availability") {
      if (!hotelId) {
        const assistantReply =
          "Bạn hãy chọn khách sạn trước nhé 😊";

        await saveMessage(
          supabase,
          user.id,
          conversationId,
          "assistant",
          assistantReply,
          {
            type: "availability",
            availability: [],
          },
        );

        return json({
          conversation_id:
            conversationId,
          type: "availability",
          availability: [],
          reply: assistantReply,
        });
      }

      if (!check_in || !check_out) {
        const assistantReply =
          "📅 Bạn muốn check-in và check-out ngày nào?";

        await saveMessage(
          supabase,
          user.id,
          conversationId,
          "assistant",
          assistantReply,
          {
            type: "availability",
            availability: [],
          },
        );

        return json({
          conversation_id:
            conversationId,
          type: "availability",
          availability: [],
          reply: assistantReply,
        });
      }

      const {
        data,
        error,
      } = await supabase.rpc(
        "get_available_room_types_v2",
        {
          p_hotel_id: hotelId,
          p_check_in: check_in,
          p_check_out: check_out,
          p_guests: guests,
        },
      );

      if (error) {
        return json({
          reply:
            "❌ Lỗi kiểm tra phòng: " +
            error.message,
        });
      }

      const rooms = data ?? [];

      const assistantReply =
        rooms.length === 0
          ? "😔 Không còn phòng trống."
          : `🛏 Phòng trống (${daysBetween(
              check_in,
              check_out,
            )} đêm):\n\n` +
            rooms
              .map(
                (r: any) =>
                  `• **${r.name}**\n💰 ${money(
                    r.price_per_night,
                  )}/đêm\n🛏 Còn ${
                    r.available_rooms
                  } phòng`,
              )
              .join("\n\n");

      await saveMessage(
        supabase,
        user.id,
        conversationId,
        "assistant",
        assistantReply,
        {
          type: "availability",
          availability: rooms,
        },
      );

      return json({
        conversation_id:
          conversationId,
        type: "availability",
        availability: rooms,
        reply: assistantReply,
      });
    }

    // ───────────────── CREATE BOOKING ─────────────────

    if (intent === "create_booking") {
      if (
        !hotelId ||
        !roomTypeId ||
        !check_in ||
        !check_out
      ) {
        const assistantReply =
          "⚠️ Thiếu thông tin đặt phòng.";

        await saveMessage(
          supabase,
          user.id,
          conversationId,
          "assistant",
          assistantReply,
          {
            type: "booking_created",
          },
        );

        return json({
          conversation_id:
            conversationId,
          type: "booking_created",
          reply: assistantReply,
        });
      }

      const { data: rt } =
        await supabase
          .from("room_types")
          .select(`
            id,
            name,
            price_per_night
          `)
          .eq("id", roomTypeId)
          .maybeSingle();

      if (!rt) {
        const assistantReply =
          "❌ Không tìm thấy loại phòng.";

        await saveMessage(
          supabase,
          user.id,
          conversationId,
          "assistant",
          assistantReply,
          {
            type: "booking_created",
          },
        );

        return json({
          conversation_id:
            conversationId,
          type: "booking_created",
          reply: assistantReply,
        });
      }

      const total =
        Number(rt.price_per_night) *
        daysBetween(
          check_in,
          check_out,
        );

      const {
        data: booking,
        error,
      } = await supabase
        .from("bookings")
        .insert({
          user_id: user.id,
          hotel_id: hotelId,
          room_type_id: roomTypeId,
          check_in,
          check_out,
          guests_adults: guests,
          guests_children: 0,
          total_price: total,
          status: "confirmed",
          payment_status: "unpaid",
        })
        .select(`
          *,
          hotels(name),
          room_types(name)
        `)
        .single();

      if (error) {
        return json({
          reply:
            "❌ Lỗi đặt phòng: " +
            error.message,
        });
      }

      const assistantReply =
        `✅ Đặt phòng thành công!\n\n` +
        `🏨 ${booking.hotels.name}\n` +
        `🛏 ${booking.room_types.name}\n` +
        `📅 ${check_in} → ${check_out}\n` +
        `💰 Tổng: ${money(total)}`;

      await saveMessage(
        supabase,
        user.id,
        conversationId,
        "assistant",
        assistantReply,
        {
          type: "booking_created",
          booking,
        },
      );

      return json({
        conversation_id:
          conversationId,
        type: "booking_created",
        booking,
        reply: assistantReply,
      });
    }

    // ───────────────── LIST BOOKINGS ─────────────────

    if (intent === "list_bookings") {
      const {
        data,
        error,
      } = await supabase
        .from("bookings")
        .select(`
          *,
          hotels(name),
          room_types(name)
        `)
        .eq("user_id", user.id)
        .order("created_at", {
          ascending: false,
        });

      if (error) {
        return json({
          reply:
            "❌ Không lấy được booking.",
        });
      }

      const bookings =
        data ?? [];

      const assistantReply =
        bookings.length === 0
          ? "📭 Bạn chưa có booking nào."
          : "📋 Booking của bạn:\n\n" +
            bookings
              .map(
                (b: any, i: number) =>
                  `${i + 1}. **${
                    b.hotels?.name
                  }**\n📅 ${b.check_in} → ${
                    b.check_out
                  }\n💰 ${money(
                    b.total_price,
                  )}`,
              )
              .join("\n\n");

      await saveMessage(
        supabase,
        user.id,
        conversationId,
        "assistant",
        assistantReply,
        {
          type: "bookings_list",
          bookings,
        },
      );

      return json({
        conversation_id:
          conversationId,
        type: "bookings_list",
        bookings,
        reply: assistantReply,
      });
    }

    // ───────────────── CANCEL BOOKING ─────────────────

    if (intent === "cancel_booking") {
      if (!bookingId) {
        const assistantReply =
          "Bạn cần cung cấp booking_id.";

        await saveMessage(
          supabase,
          user.id,
          conversationId,
          "assistant",
          assistantReply,
          {
            type: "booking_cancelled",
          },
        );

        return json({
          conversation_id:
            conversationId,
          type: "booking_cancelled",
          reply: assistantReply,
        });
      }

      const {
        data: booking,
        error,
      } = await supabase
        .from("bookings")
        .update({
          status: "cancelled",
        })
        .eq("id", bookingId)
        .eq("user_id", user.id)
        .select()
        .maybeSingle();

      if (error || !booking) {
        const assistantReply =
          "❌ Không thể hủy booking.";

        await saveMessage(
          supabase,
          user.id,
          conversationId,
          "assistant",
          assistantReply,
          {
            type: "booking_cancelled",
          },
        );

        return json({
          conversation_id:
            conversationId,
          type: "booking_cancelled",
          reply: assistantReply,
        });
      }

      const assistantReply =
        "✅ Đã hủy booking thành công.";

      await saveMessage(
        supabase,
        user.id,
        conversationId,
        "assistant",
        assistantReply,
        {
          type: "booking_cancelled",
          booking,
        },
      );

      return json({
        conversation_id:
          conversationId,
        type: "booking_cancelled",
        booking,
        reply: assistantReply,
      });
    }

    // ───────────────── GENERAL CHAT ─────────────────

    const reply = await callGroq({
      apiKey: groqKey,
      model: groqModel,
      systemPrompt: `
Bạn là trợ lý AI booking khách sạn.

Chỉ trả lời về:
- khách sạn
- du lịch
- booking
- phòng
- thanh toán

Trả lời tiếng Việt thân thiện.
      `,
      userMessage: message,
    });

    await saveMessage(
      supabase,
      user.id,
      conversationId,
      "assistant",
      reply,
      {
        type: "general_chat",
      },
    );

    return json({
      conversation_id:
        conversationId,
      type: "general_chat",
      reply,
    });

  } catch (e) {
    return json(
      {
        reply: "⚠️ Có lỗi hệ thống.",
        error:
          e instanceof Error
            ? e.message
            : String(e),
      },
      500,
    );
  }
});