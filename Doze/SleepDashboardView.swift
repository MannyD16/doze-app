//
//  SleepDashboardView.swift
//  Doze
//
//  Created by Manuel Diaz on 4/2/25.
//

import SwiftUI
import CoreData

struct SleepDashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: SleepSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SleepSession.startTime, ascending: false)]
    ) private var sessions: FetchedResults<SleepSession>

    @State private var showLogSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("Sleep History")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        showLogSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                if sessions.isEmpty {
                    Spacer()
                    Text("No sleep sessions yet")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(sessions, id: \.id) { session in
                            sessionCard(for: session)
                        }
                        .onDelete(perform: deleteSession)
                    }
                    .listStyle(.plain)
                    .background(Color.black)
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            SleepLogView()
        }
    }

    private func deleteSession(at offsets: IndexSet) {
        offsets.map { sessions[$0] }.forEach(context.delete)
        do {
            try context.save()
        } catch {
            print("Error deleting session: \(error)")
        }
    }

    private func sessionCard(for session: SleepSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(formattedDate(session.startTime))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(formattedDuration(session.duration))
                    .foregroundColor(.purple)
                    .font(.subheadline)
            }
            Divider().background(Color.purple.opacity(0.5))
            if let mood = session.mood, !mood.isEmpty {
                Text("Mood: \(mood)").italic().foregroundColor(.gray)
            }
            if let notes = session.notes, !notes.isEmpty {
                Text("Notes: \(notes)").foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
        )
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedDuration(_ duration: Double) -> String {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours) hrs \(minutes) min"
    }
}

#Preview {
    SleepDashboardView()
}


